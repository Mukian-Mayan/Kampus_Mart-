import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class MtnMomoConfig {
  // PLACE YOUR ACTUAL CREDENTIALS HERE
  // These are example credentials - replace with your actual ones
  static const String apiUser = '965c4df9-4cbb-4402-a70c-80054a1910c0';
  static const String apiKey = '4dbc3064d0c54b039106e38e7f6799df';
  static const String subscriptionKey = '63a7eccd5a624ec281b5eb5511cc022e';
  static const String callbackUrl = 'https://a27df728036c.ngrok-free.app';

  // Environment URLs
  static const String sandboxBaseUrl = 'https://sandbox.momodeveloper.mtn.com';
  static const String productionBaseUrl =
      'https://ericssonbasicapi2.azure-api.net';

  // Use sandbox for testing
  static const String baseUrl = sandboxBaseUrl;
  static const String targetEnvironment = 'sandbox'; // or 'production'
}

class MtnMomoService {
  static const String _collectionsPath = '/collection/v1_0';
  static const String _disbursementsPath = '/disbursement/v1_0';

  // Generate Bearer Token with improved error handling
  static Future<String?> _generateAccessToken(String product) async {
    final credentials = base64Encode(
      utf8.encode('${MtnMomoConfig.apiUser}:${MtnMomoConfig.apiKey}'),
    );

    try {
      print('Generating token for product: $product');
      print('API User: ${MtnMomoConfig.apiUser}');
      print('Base URL: ${MtnMomoConfig.baseUrl}');

      final response = await http.post(
        Uri.parse('${MtnMomoConfig.baseUrl}/$product/token/'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Ocp-Apim-Subscription-Key': MtnMomoConfig.subscriptionKey,
          'Content-Type': 'application/json',
        },
      );

      print('Token response status: ${response.statusCode}');
      print('Token response body: ${response.body}');
      print('Token response headers: ${response.headers}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Access token generated successfully');
        return data['access_token'];
      } else {
        print('Failed to generate token: ${response.statusCode}');
        print('Error response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error generating access token: $e');
      return null;
    }
  }

  // Request to Pay (Collections) with improved error handling
  static Future<Map<String, dynamic>> requestToPay({
    required String amount,
    required String currency,
    required String phoneNumber,
    required String payerMessage,
    required String payeeNote,
  }) async {
    print('Starting requestToPay...');

    final token = await _generateAccessToken('collection');
    if (token == null) {
      return {'success': false, 'message': 'Failed to generate access token'};
    }

    final referenceId = const Uuid().v4();
    print('Generated reference ID: $referenceId');

    final requestBody = {
      'amount': amount,
      'currency': currency,
      'externalId': referenceId,
      'payer': {'partyIdType': 'MSISDN', 'partyId': phoneNumber},
      'payerMessage': payerMessage,
      'payeeNote': payeeNote,
    };

    print('Request body: ${json.encode(requestBody)}');

    try {
      final response = await http.post(
        Uri.parse('${MtnMomoConfig.baseUrl}$_collectionsPath/requesttopay'),
        headers: {
          'Authorization': 'Bearer $token',
          'X-Reference-Id': referenceId,
          'X-Target-Environment': MtnMomoConfig.targetEnvironment,
          'Ocp-Apim-Subscription-Key': MtnMomoConfig.subscriptionKey,
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('RequestToPay response status: ${response.statusCode}');
      print('RequestToPay response body: ${response.body}');
      print('RequestToPay response headers: ${response.headers}');

      if (response.statusCode == 202) {
        return {
          'success': true,
          'referenceId': referenceId,
          'message': 'Payment request sent successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Payment request failed: ${response.statusCode}',
          'error': response.body,
        };
      }
    } catch (e) {
      print('Network error in requestToPay: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Check Payment Status with improved error handling
  static Future<Map<String, dynamic>> checkPaymentStatus(
    String referenceId,
  ) async {
    print('Checking payment status for: $referenceId');

    final token = await _generateAccessToken('collection');
    if (token == null) {
      return {'success': false, 'message': 'Failed to generate access token'};
    }

    try {
      final response = await http.get(
        Uri.parse(
          '${MtnMomoConfig.baseUrl}$_collectionsPath/requesttopay/$referenceId',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'X-Target-Environment': MtnMomoConfig.targetEnvironment,
          'Ocp-Apim-Subscription-Key': MtnMomoConfig.subscriptionKey,
        },
      );

      print('Payment status response: ${response.statusCode}');
      print('Payment status body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'status': data['status'], 'data': data};
      } else {
        return {
          'success': false,
          'message': 'Failed to check status: ${response.statusCode}',
          'error': response.body,
        };
      }
    } catch (e) {
      print('Network error in checkPaymentStatus: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Get Account Balance with improved error handling
  static Future<Map<String, dynamic>> getAccountBalance() async {
    print('Getting account balance...');

    final token = await _generateAccessToken('collection');
    if (token == null) {
      return {'success': false, 'message': 'Failed to generate access token'};
    }

    try {
      final response = await http.get(
        Uri.parse('${MtnMomoConfig.baseUrl}$_collectionsPath/account/balance'),
        headers: {
          'Authorization': 'Bearer $token',
          'X-Target-Environment': MtnMomoConfig.targetEnvironment,
          'Ocp-Apim-Subscription-Key': MtnMomoConfig.subscriptionKey,
        },
      );

      print('Balance response status: ${response.statusCode}');
      print('Balance response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'balance': data['availableBalance'],
          'currency': data['currency'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to get balance: ${response.statusCode}',
          'error': response.body,
        };
      }
    } catch (e) {
      print('Network error in getAccountBalance: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Transfer Money (Disbursements) with improved error handling
  static Future<Map<String, dynamic>> transfer({
    required String amount,
    required String currency,
    required String phoneNumber,
    required String payerMessage,
    required String payeeNote,
  }) async {
    print('Starting transfer...');

    final token = await _generateAccessToken('disbursement');
    if (token == null) {
      return {'success': false, 'message': 'Failed to generate access token'};
    }

    final referenceId = const Uuid().v4();
    print('Generated transfer reference ID: $referenceId');

    final requestBody = {
      'amount': amount,
      'currency': currency,
      'externalId': referenceId,
      'payee': {'partyIdType': 'MSISDN', 'partyId': phoneNumber},
      'payerMessage': payerMessage,
      'payeeNote': payeeNote,
    };

    try {
      final response = await http.post(
        Uri.parse('${MtnMomoConfig.baseUrl}$_disbursementsPath/transfer'),
        headers: {
          'Authorization': 'Bearer $token',
          'X-Reference-Id': referenceId,
          'X-Target-Environment': MtnMomoConfig.targetEnvironment,
          'Ocp-Apim-Subscription-Key': MtnMomoConfig.subscriptionKey,
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('Transfer response status: ${response.statusCode}');
      print('Transfer response body: ${response.body}');

      if (response.statusCode == 202) {
        return {
          'success': true,
          'referenceId': referenceId,
          'message': 'Transfer request sent successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Transfer request failed: ${response.statusCode}',
          'error': response.body,
        };
      }
    } catch (e) {
      print('Network error in transfer: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Helper method to create API User (for initial setup)
  static Future<Map<String, dynamic>> createApiUser() async {
    final referenceId = const Uuid().v4();

    try {
      final response = await http.post(
        Uri.parse('${MtnMomoConfig.baseUrl}/v1_0/apiuser'),
        headers: {
          'X-Reference-Id': referenceId,
          'Ocp-Apim-Subscription-Key': MtnMomoConfig.subscriptionKey,
          'Content-Type': 'application/json',
        },
        body: json.encode({'providerCallbackHost': MtnMomoConfig.callbackUrl}),
      );

      print('Create API User response: ${response.statusCode}');
      print('Create API User body: ${response.body}');

      if (response.statusCode == 201) {
        return {
          'success': true,
          'apiUserId': referenceId,
          'message': 'API User created successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to create API User: ${response.statusCode}',
          'error': response.body,
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Helper method to create API Key (for initial setup)
  static Future<Map<String, dynamic>> createApiKey(String apiUserId) async {
    try {
      final response = await http.post(
        Uri.parse('${MtnMomoConfig.baseUrl}/v1_0/apiuser/$apiUserId/apikey'),
        headers: {
          'Ocp-Apim-Subscription-Key': MtnMomoConfig.subscriptionKey,
          'Content-Type': 'application/json',
        },
      );

      print('Create API Key response: ${response.statusCode}');
      print('Create API Key body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'apiKey': data['apiKey'],
          'message': 'API Key created successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to create API Key: ${response.statusCode}',
          'error': response.body,
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}

// Example Usage Widget with improved UI and error handling
class MtnMomoPage extends StatefulWidget {
  @override
  _MtnMomoPageState createState() => _MtnMomoPageState();
}

class _MtnMomoPageState extends State<MtnMomoPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isLoading = false;
  String _result = '';
  String _referenceId = '';

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _requestPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _result = '';
    });

    final result = await MtnMomoService.requestToPay(
      amount: _amountController.text,
      currency: 'EUR', // Change to UGX for Uganda
      phoneNumber: _phoneController.text,
      payerMessage: _messageController.text,
      payeeNote: 'Payment for services',
    );

    setState(() {
      _isLoading = false;
      if (result['success']) {
        _referenceId = result['referenceId'];
        _result = 'Payment request sent!\nReference: $_referenceId';
      } else {
        _result = 'Error: ${result['message']}';
      }
    });
  }

  Future<void> _checkPaymentStatus() async {
    if (_referenceId.isEmpty) {
      setState(() {
        _result = 'No reference ID available. Make a payment request first.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _result = '';
    });

    final result = await MtnMomoService.checkPaymentStatus(_referenceId);

    setState(() {
      _isLoading = false;
      if (result['success']) {
        _result = 'Payment Status: ${result['status']}';
      } else {
        _result = 'Error: ${result['message']}';
      }
    });
  }

  Future<void> _checkBalance() async {
    setState(() {
      _isLoading = true;
      _result = '';
    });

    final result = await MtnMomoService.getAccountBalance();

    setState(() {
      _isLoading = false;
      if (result['success']) {
        _result = 'Balance: ${result['balance']} ${result['currency']}';
      } else {
        _result = 'Error: ${result['message']}';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MTN MoMo Integration'),
        backgroundColor: Colors.yellow[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: Icon(Icons.money),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                  hintText: '256XXXXXXXXX',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _messageController,
                decoration: InputDecoration(
                  labelText: 'Message',
                  prefixIcon: Icon(Icons.message),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _requestPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[700],
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text('Request Payment'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _checkPaymentStatus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text('Check Status'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _checkBalance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Check Balance'),
              ),
              SizedBox(height: 24),
              if (_result.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    _result,
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
