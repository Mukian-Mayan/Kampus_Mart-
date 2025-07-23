const functions = require('firebase-functions');
const express = require('express');
const cors = require('cors');
const axios = require('axios');
const { v4: uuidv4 } = require('uuid');

const app = express();
app.use(cors({ origin: true }));
app.use(express.json());

// MoMo Config
const config = {
  apiUser: '965c4df9-4cbb-4402-a70c-80054a1910c0',
  apiKey: '4dbc3064d0c54b039106e38e7f6799df',
  subscriptionKey: '63a7eccd5a624ec281b5eb5511cc022e',
  callbackUrl: 'https://a27df728036c.ngrok-free.app',
  baseUrl: 'https://sandbox.momodeveloper.mtn.com',
  targetEnvironment: 'sandbox',
};

// Create Basic Auth header
const getBasicAuthHeader = () => {
  const credentials = Buffer.from(`${config.apiUser}:${config.apiKey}`).toString('base64');
  return `Basic ${credentials}`;
};

// Get Bearer Token with error handling
const getAccessToken = async () => {
  try {
    const response = await axios.post(
      `${config.baseUrl}/collection/token/`,
      {},
      {
        headers: {
          Authorization: getBasicAuthHeader(),
          'Ocp-Apim-Subscription-Key': config.subscriptionKey,
        },
      }
    );

    return response.data.access_token;
  } catch (error) {
    console.error('Error getting access token:', error.response?.data || error.message);
    throw new Error('Failed to get access token');
  }
};

// Enhanced input validation
const validateRequestToPay = (body) => {
  const { amount, currency, phoneNumber } = body;
  const errors = [];

  // Amount validation
  if (!amount) {
    errors.push('Amount is required');
  } else if (isNaN(amount) || parseFloat(amount) <= 0) {
    errors.push('Amount must be a positive number');
  }
  
  // Currency validation
  if (!currency) {
    errors.push('Currency is required');
  } else if (typeof currency !== 'string' || currency.length !== 3) {
    errors.push('Currency must be a valid 3-letter code (e.g., EUR, USD)');
  }
  
  // Phone number validation
  if (!phoneNumber) {
    errors.push('Phone number is required');
  } else if (typeof phoneNumber !== 'string') {
    errors.push('Phone number must be a string');
  } else {
    // Basic phone number format validation
    const cleanPhone = phoneNumber.replace(/^\+/, '');
    if (!/^\d{9,15}$/.test(cleanPhone)) {
      errors.push('Phone number must contain 9-15 digits');
    }
  }

  return errors;
};

// Route: Request to Pay
app.post('/requestToPay', async (req, res) => {
  try {
    console.log('Request body:', req.body);

    // Validate input
    const validationErrors = validateRequestToPay(req.body);
    if (validationErrors.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Validation errors',
        errors: validationErrors,
      });
    }

    const { amount, currency, phoneNumber, payerMessage, payeeNote } = req.body;
    const referenceId = uuidv4();

    // Get access token
    const token = await getAccessToken();

    // Clean phone number (remove + and any spaces)
    const cleanPhoneNumber = phoneNumber.replace(/^\+/, '').replace(/\s/g, '');

    const requestBody = {
      amount: parseFloat(amount).toString(), // Ensure proper number formatting
      currency: currency.toUpperCase(), // Ensure uppercase currency
      externalId: referenceId,
      payer: { 
        partyIdType: 'MSISDN', 
        partyId: cleanPhoneNumber
      },
      payerMessage: payerMessage || 'Payment request',
      payeeNote: payeeNote || 'Payment for service',
    };

    console.log('MTN API Request body:', requestBody);

    const response = await axios.post(
      `${config.baseUrl}/collection/v1_0/requesttopay`,
      requestBody,
      {
        headers: {
          Authorization: `Bearer ${token}`,
          'X-Reference-Id': referenceId,
          'X-Target-Environment': config.targetEnvironment,
          'Ocp-Apim-Subscription-Key': config.subscriptionKey,
          'Content-Type': 'application/json',
        },
      }
    );

    console.log('MTN API Response:', response.status, response.data);

    // Return consistent response format
    res.status(202).json({
      success: true,
      message: 'Payment request sent successfully',
      data: {
        referenceId,
        status: 'PENDING',
        amount: parseFloat(amount),
        currency: currency.toUpperCase(),
        phoneNumber: cleanPhoneNumber,
      }
    });

  } catch (error) {
    console.error('Request to pay error:', error.response?.data || error.message);
    
    // Handle specific MTN MoMo API errors
    if (error.response?.status === 400) {
      return res.status(400).json({
        success: false,
        message: 'Invalid request parameters',
        error: error.response.data,
      });
    }
    
    if (error.response?.status === 409) {
      return res.status(409).json({
        success: false,
        message: 'Duplicate transaction reference',
        error: 'Reference ID already exists',
      });
    }

    if (error.response?.status === 500) {
      return res.status(500).json({
        success: false,
        message: 'MTN MoMo service temporarily unavailable',
        error: 'Please try again later',
      });
    }

    res.status(500).json({
      success: false,
      message: 'Failed to request payment',
      error: error.response?.data?.message || error.message,
    });
  }
});

// Route: Check Payment Status
app.get('/checkPaymentStatus/:referenceId', async (req, res) => {
  try {
    const { referenceId } = req.params;

    // Validate referenceId format
    if (!referenceId || typeof referenceId !== 'string') {
      return res.status(400).json({
        success: false,
        message: 'Valid reference ID is required',
      });
    }

    // Basic UUID format validation
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
    if (!uuidRegex.test(referenceId)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid reference ID format',
      });
    }

    const token = await getAccessToken();

    const response = await axios.get(
      `${config.baseUrl}/collection/v1_0/requesttopay/${referenceId}`,
      {
        headers: {
          Authorization: `Bearer ${token}`,
          'X-Target-Environment': config.targetEnvironment,
          'Ocp-Apim-Subscription-Key': config.subscriptionKey,
        },
      }
    );

    console.log('Payment status response:', response.data);

    // Return consistent response format
    res.json({
      success: true,
      message: 'Payment status retrieved successfully',
      data: {
        referenceId,
        status: response.data.status,
        amount: response.data.amount,
        currency: response.data.currency,
        financialTransactionId: response.data.financialTransactionId,
        externalId: response.data.externalId,
        payer: response.data.payer,
        payerMessage: response.data.payerMessage,
        payeeNote: response.data.payeeNote,
      }
    });

  } catch (error) {
    console.error('Check payment status error:', error.response?.data || error.message);
    
    if (error.response?.status === 404) {
      return res.status(404).json({
        success: false,
        message: 'Transaction not found',
        error: 'Reference ID does not exist or transaction has expired',
      });
    }

    res.status(500).json({
      success: false,
      message: 'Failed to check payment status',
      error: error.response?.data?.message || error.message,
    });
  }
});

// Route: Get Account Balance
app.get('/getBalance', async (req, res) => {
  try {
    const token = await getAccessToken();

    const response = await axios.get(
      `${config.baseUrl}/collection/v1_0/account/balance`,
      {
        headers: {
          Authorization: `Bearer ${token}`,
          'X-Target-Environment': config.targetEnvironment,
          'Ocp-Apim-Subscription-Key': config.subscriptionKey,
        },
      }
    );

    console.log('Balance response:', response.data);

    // Return consistent response format
    res.json({
      success: true,
      message: 'Account balance retrieved successfully',
      data: {
        availableBalance: response.data.availableBalance,
        currency: response.data.currency,
      }
    });

  } catch (error) {
    console.error('Get balance error:', error.response?.data || error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve account balance',
      error: error.response?.data?.message || error.message,
    });
  }
});

// Route: Get Account Information
app.get('/getAccountInfo', async (req, res) => {
  try {
    const token = await getAccessToken();

    const response = await axios.get(
      `${config.baseUrl}/collection/v1_0/accountholder/msisdn/${config.apiUser}/basicuserinfo`,
      {
        headers: {
          Authorization: `Bearer ${token}`,
          'X-Target-Environment': config.targetEnvironment,
          'Ocp-Apim-Subscription-Key': config.subscriptionKey,
        },
      }
    );

    res.json({
      success: true,
      message: 'Account information retrieved successfully',
      data: response.data,
    });

  } catch (error) {
    console.error('Get account info error:', error.response?.data || error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve account information',
      error: error.response?.data?.message || error.message,
    });
  }
});

// Health check endpoint with more details
app.get('/health', (req, res) => {
  res.json({ 
    success: true, 
    message: 'MTN MoMo API service is running',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
    environment: config.targetEnvironment,
  });
});

// Route to test configuration
app.get('/config/test', async (req, res) => {
  try {
    // Test if we can get an access token
    const token = await getAccessToken();
    
    res.json({
      success: true,
      message: 'Configuration is valid',
      data: {
        hasToken: !!token,
        environment: config.targetEnvironment,
        baseUrl: config.baseUrl,
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Configuration test failed',
      error: error.message,
    });
  }
});

// Handle 404 for unknown routes
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Endpoint not found',
    availableEndpoints: [
      'POST /requestToPay',
      'GET /checkPaymentStatus/:referenceId',
      'GET /getBalance',
      'GET /getAccountInfo',
      'GET /health',
      'GET /config/test'
    ]
  });
});

// Global error handler
app.use((error, req, res, next) => {
  console.error('Unhandled error:', error);
  res.status(500).json({
    success: false,
    message: 'Internal server error',
    error: process.env.NODE_ENV === 'development' ? error.message : 'Something went wrong',
  });
});

// Export as Firebase Function
exports.momoApi = functions.https.onRequest(app);