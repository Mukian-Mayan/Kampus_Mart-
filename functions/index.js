/* eslint-disable max-len */
/* eslint-disable no-unused-vars */
/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const logger = require("firebase-functions/logger");
const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.


// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

// ============================================
// PRODUCT AND CATEGORY MANAGEMENT FUNCTIONS
// ============================================

// Update category product count when a product is created
// Enhanced product count management functions

// Update category product count when a product is created
exports.onProductCreate = functions
    .firestore
    .document("products/{productId}")
    .onCreate(async (snap, context) => {
      try {
        const productData = snap.data();
        const categoryId = productData.categoryId;

        if (categoryId) {
          await db.collection("categories").doc(categoryId).update({
            productCount: admin.firestore.FieldValue.increment(1),
          });

          logger.info(`Incremented product count for category ${categoryId}`);
        }
      } catch (error) {
        logger.error("Error updating category count on product create:", error);
      }
    });

// Update category product count when a product is deleted
exports.onProductDelete = functions
    .firestore
    .document("products/{productId}")
    .onDelete(async (snap, context) => {
      try {
        const productData = snap.data();
        const categoryId = productData.categoryId;

        if (categoryId) {
          const categoryRef = db.collection("categories").doc(categoryId);
          const categoryDoc = await categoryRef.get();

          if (categoryDoc.exists) {
            const currentCount = categoryDoc.data().productCount || 0;

            if (currentCount > 0) {
              await categoryRef.update({
                productCount: admin.firestore.FieldValue.increment(-1),
              });

              logger.info(`Decremented product count for category ${categoryId}`);
            }
          }
        }
      } catch (error) {
        logger.error("Error updating category count on product delete:", error);
      }
    });

// Function to manually fix product counts if they get out of sync
exports.fixProductCounts = functions.https.onCall(async (data, context) => {
  try {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }

    const batch = db.batch();
    const categoriesSnapshot = await db.collection("categories").get();
    const fixes = [];

    for (const categoryDoc of categoriesSnapshot.docs) {
      const categoryId = categoryDoc.id;
      const categoryData = categoryDoc.data();
      const storedCount = categoryData.productCount || 0;

      // Count actual products in this category
      const productsSnapshot = await db.collection("products")
          .where("categoryId", "==", categoryId)
          .get();

      const actualCount = productsSnapshot.size;

      if (storedCount !== actualCount) {
        batch.update(categoryDoc.ref, { productCount: actualCount });
        fixes.push({
          categoryId,
          oldCount: storedCount,
          newCount: actualCount,
        });

        logger.info(`Fixed category ${categoryId}: ${storedCount} -> ${actualCount}`);
      }
    }

    await batch.commit();

    return {
      success: true,
      message: `Fixed ${fixes.length} categories`,
      fixes: fixes,
    };
  } catch (error) {
    logger.error("Error fixing product counts:", error);
    throw new functions.https.HttpsError("internal", "Failed to fix product counts");
  }
});
// Update category product count when a product is updated
exports.onProductUpdate = functions
    .firestore
    .document("products/{productId}")
    .onUpdate(async (change, context) => {
      try {
        const beforeData = change.before.data();
        const afterData = change.after.data();

        const oldCategoryId = beforeData.categoryId;
        const newCategoryId = afterData.categoryId;
        const oldIsActive = beforeData.isActive;
        const newIsActive = afterData.isActive;

        // Handle category change
        if (oldCategoryId !== newCategoryId) {
          if (oldCategoryId && oldIsActive) {
            const oldCategoryRef = db.collection("categories").doc(oldCategoryId);
            const oldCategoryDoc = await oldCategoryRef.get();

            if (oldCategoryDoc.exists) {
              const currentCount = oldCategoryDoc.data().productCount || 0;
              if (currentCount > 0) {
                await oldCategoryRef.update({
                  productCount: admin.firestore.FieldValue.increment(-1),
                });
              }
            }
          }

          if (newCategoryId && newIsActive) {
            await db.collection("categories").doc(newCategoryId).update({
              productCount: admin.firestore.FieldValue.increment(1),
            });
          }
        }

        // Handle activation/deactivation
        if (oldIsActive !== newIsActive && oldCategoryId === newCategoryId) {
          const categoryId = newCategoryId;

          if (categoryId) {
            const increment = newIsActive ? 1 : -1;

            if (!newIsActive) {
              const categoryRef = db.collection("categories").doc(categoryId);
              const categoryDoc = await categoryRef.get();

              if (categoryDoc.exists) {
                const currentCount = categoryDoc.data().productCount || 0;
                if (currentCount > 0) {
                  await categoryRef.update({
                    productCount: admin.firestore.FieldValue.increment(increment),
                  });
                }
              }
            } else {
              await db.collection("categories").doc(categoryId).update({
                productCount: admin.firestore.FieldValue.increment(increment),
              });
            }
          }
        }

        logger.info("Successfully handled product update for category counts");
      } catch (error) {
        logger.error("Error updating category count on product update:", error);
      }
    });

// ============================================
// ORDER PROCESSING FUNCTIONS
// ============================================

// Handle order status updates
exports.onOrderStatusUpdate = functions
    .firestore
    .document("orders/{orderId}")
    .onUpdate(async (change, context) => {
      try {
        const beforeData = change.before.data();
        const afterData = change.after.data();

        const oldStatus = beforeData.status;
        const newStatus = afterData.status;

        if (oldStatus !== newStatus) {
        // Update product stock when order is completed
          if (newStatus === "completed") {
            const orderItems = afterData.items || [];

            for (const item of orderItems) {
              const productRef = db.collection("products").doc(item.productId);
              await productRef.update({
                stock: admin.firestore.FieldValue.increment(-item.quantity),
                soldCount: admin.firestore.FieldValue.increment(item.quantity),
              });
            }

            logger.info(`Updated stock for completed order ${context.params.orderId}`);
          }

          // Restore stock if order is cancelled
          if (newStatus === "cancelled" && oldStatus !== "cancelled") {
            const orderItems = afterData.items || [];

            for (const item of orderItems) {
              const productRef = db.collection("products").doc(item.productId);
              await productRef.update({
                stock: admin.firestore.FieldValue.increment(item.quantity),
                soldCount: admin.firestore.FieldValue.increment(-item.quantity),
              });
            }

            logger.info(`Restored stock for cancelled order ${context.params.orderId}`);
          }
        }
      } catch (error) {
        logger.error("Error handling order status update:", error);
      }
    });

// ============================================
// NOTIFICATION FUNCTIONS
// ============================================

// Send notification when order status changes
exports.sendOrderNotification = functions
    .firestore
    .document("orders/{orderId}")
    .onUpdate(async (change, context) => {
      try {
        const beforeData = change.before.data();
        const afterData = change.after.data();

        if (beforeData.status !== afterData.status) {
          const userId = afterData.userId;
          const orderId = context.params.orderId;

          // Get user's FCM token
          const userDoc = await db.collection("users").doc(userId).get();
          if (userDoc.exists && userDoc.data().fcmToken) {
            const message = {
              token: userDoc.data().fcmToken,
              notification: {
                title: "Order Status Updated",
                body: `Your order ${orderId} status changed to ${afterData.status}`,
              },
              data: {
                orderId: orderId,
                status: afterData.status,
                type: "order_update",
              },
            };

            await admin.messaging().send(message);
            logger.info(`Notification sent for order ${orderId} status change`);
          }
        }
      } catch (error) {
        logger.error("Error sending order notification:", error);
      }
    });

// ============================================
// UTILITY AND MAINTENANCE FUNCTIONS
// ============================================

// Manual function to recalculate all category product counts
exports.recalculateCategoryCounts = functions.https.onCall(async (data, context) => {
  try {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }

    const batch = db.batch();
    const categoriesSnapshot = await db.collection("categories").get();

    for (const categoryDoc of categoriesSnapshot.docs) {
      const categoryId = categoryDoc.id;

      const productsSnapshot = await db.collection("products")
          .where("categoryId", "==", categoryId)
          .where("isActive", "==", true)
          .get();

      const productCount = productsSnapshot.size;
      batch.update(categoryDoc.ref, {productCount: productCount});
    }

    await batch.commit();

    return {
      success: true,
      message: `Recalculated product counts for ${categoriesSnapshot.size} categories`,
    };
  } catch (error) {
    logger.error("Error recalculating category counts:", error);
    throw new functions.https.HttpsError("internal", "Failed to recalculate category counts");
  }
});

// Scheduled function to verify and fix category counts
exports.verifyCategoryCounts = functions.pubsub
    .schedule("0 2 * * *")
    .timeZone("UTC")
    .onRun(async (context) => {
      try {
        logger.info("Starting daily category count verification...");

        const categoriesSnapshot = await db.collection("categories").get();
        const fixes = [];

        for (const categoryDoc of categoriesSnapshot.docs) {
          const categoryId = categoryDoc.id;
          const categoryData = categoryDoc.data();
          const storedCount = categoryData.productCount || 0;

          const productsSnapshot = await db.collection("products")
              .where("categoryId", "==", categoryId)
              .where("isActive", "==", true)
              .get();

          const actualCount = productsSnapshot.size;

          if (storedCount !== actualCount) {
            await categoryDoc.ref.update({productCount: actualCount});
            fixes.push({
              categoryId,
              oldCount: storedCount,
              newCount: actualCount,
            });

            logger.info(`Fixed category ${categoryId}: ${storedCount} -> ${actualCount}`);
          }
        }

        logger.info(`Category count verification completed. Fixed ${fixes.length} categories.`);
        return {success: true, fixes};
      } catch (error) {
        logger.error("Error in category count verification:", error);
        return {success: false, error: error.message};
      }
    });

// ============================================
// ANALYTICS AND REPORTING FUNCTIONS
// ============================================

// Generate sales report
exports.generateSalesReport = functions.https.onCall(async (data, context) => {
  try {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }

    const {sellerId, startDate, endDate} = data;

    let query = db.collection("orders")
        .where("sellerId", "==", sellerId)
        .where("status", "==", "completed");

    if (startDate) {
      query = query.where("createdAt", ">=", new Date(startDate));
    }
    if (endDate) {
      query = query.where("createdAt", "<=", new Date(endDate));
    }

    const ordersSnapshot = await query.get();
    const orders = ordersSnapshot.docs.map((doc) => ({id: doc.id, ...doc.data()}));

    const totalSales = orders.reduce((sum, order) => sum + (order.totalAmount || 0), 0);
    const totalOrders = orders.length;

    return {
      success: true,
      data: {
        totalSales,
        totalOrders,
        orders,
      },
    };
  } catch (error) {
    logger.error("Error generating sales report:", error);
    throw new functions.https.HttpsError("internal", "Failed to generate sales report");
  }
});

// Clean up old cart items
exports.cleanupOldCartItems = functions.pubsub
    .schedule("0 1 * * *")
    .timeZone("UTC")
    .onRun(async (context) => {
      try {
        logger.info("Starting cleanup of old cart items...");

        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

        const oldCartItems = await db.collection("cart")
            .where("createdAt", "<", thirtyDaysAgo)
            .get();

        const batch = db.batch();
        oldCartItems.docs.forEach((doc) => {
          batch.delete(doc.ref);
        });

        await batch.commit();

        logger.info(`Cleaned up ${oldCartItems.docs.length} old cart items`);
        return {success: true, cleaned: oldCartItems.docs.length};
      } catch (error) {
        logger.error("Error cleaning up old cart items:", error);
        return {success: false, error: error.message};
      }
    });

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