import 'dart:convert';
import 'package:http/http.dart' as http;

class MtnMomoConfig {
  // Your Firebase Cloud Run backend URL
  static const String firebaseBackendUrl =
      'https://momoapi-zdkmlvszmq-uc.a.run.app';

  // Use Firebase backend instead of MTN MoMo direct URLs
  static const String baseUrl = firebaseBackendUrl;

  // These might not be needed anymore since Firebase backend handles them
  // Keep them if your backend expects them
  static const String apiUser = '965c4df9-4cbb-4402-a70c-80054a1910c0';
  static const String apiKey = '4dbc3064d0c54b039106e38e7f6799df';
  static const String subscriptionKey = '63a7eccd5a624ec281b5eb5511cc022e';
  static const String targetEnvironment = 'sandbox';
}

class MtnMomoService {
  // Update these paths to match your Firebase backend API routes
  static const String _collectionsPath = '';
  static const String _disbursementsPath = '';
  static const String _tokenPath = '';

  // Token generation is handled by the Firebase backend, so this method is not needed
  // Keeping it for reference but it won't be used
  static Future<String?> _generateAccessToken(String product) async {
    // Not needed - Firebase backend handles authentication
    return null;
  }

  // Simplified request to pay - Firebase backend handles MTN MoMo API calls
  static Future<Map<String, dynamic>> requestToPay({
    required String amount,
    required String currency,
    required String phoneNumber,
    required String payerMessage,
    required String payeeNote,
  }) async {
    print('Starting requestToPay via Firebase backend...');

    final requestBody = {
      'amount': amount,
      'currency': 'EUR', // Keep EUR as hardcoded currency
      'phoneNumber': phoneNumber,
      'payerMessage': payerMessage,
      'payeeNote': payeeNote,
      'environment': MtnMomoConfig.targetEnvironment,
    };

    try {
      final response = await http.post(
        Uri.parse('${MtnMomoConfig.baseUrl}/requestToPay'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      print('RequestToPay response status: ${response.statusCode}');
      print('RequestToPay response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 202) {
        final data = json.decode(response.body);

        // Backend returns data in nested structure
        if (data['success'] == true && data['data'] != null) {
          return {
            'success': true,
            'referenceId': data['data']['referenceId'],
            'message': data['message'] ?? 'Payment request sent successfully',
            'status': data['data']['status'],
            'amount': data['data']['amount'],
            'currency': data['data']['currency'],
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Payment request failed',
            'errors': data['errors'],
          };
        }
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Payment request failed',
          'error': errorData['error'],
          'errors': errorData['errors'],
        };
      }
    } catch (e) {
      print('Network error in requestToPay: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Check payment status via Firebase backend
  static Future<Map<String, dynamic>> checkPaymentStatus(
    String referenceId,
  ) async {
    print('Checking payment status via Firebase backend: $referenceId');

    try {
      final response = await http.get(
        Uri.parse('${MtnMomoConfig.baseUrl}/checkPaymentStatus/$referenceId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Payment status response: ${response.statusCode}');
      print('Payment status body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Backend returns data in nested structure
        if (data['success'] == true && data['data'] != null) {
          return {
            'success': true,
            'status': data['data']['status'],
            'data': data['data'],
            'message': data['message'],
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Failed to check status',
            'error': data['error'],
          };
        }
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to check status',
          'error': errorData['error'],
        };
      }
    } catch (e) {
      print('Network error in checkPaymentStatus: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Get account balance via Firebase backend
  static Future<Map<String, dynamic>> getAccountBalance() async {
    print('Getting account balance via Firebase backend...');

    try {
      final response = await http.get(
        Uri.parse('${MtnMomoConfig.baseUrl}/getBalance'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Balance response status: ${response.statusCode}');
      print('Balance response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Backend returns data in nested structure
        if (data['success'] == true && data['data'] != null) {
          return {
            'success': true,
            'balance': data['data']['availableBalance'],
            'currency': data['data']['currency'],
            'message': data['message'],
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Failed to get balance',
            'error': data['error'],
          };
        }
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to get balance',
          'error': errorData['error'],
        };
      }
    } catch (e) {
      print('Network error in getAccountBalance: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Transfer method - Note: Your backend doesn't have a transfer endpoint
  // This method won't work until you add a transfer endpoint to your Firebase backend
  static Future<Map<String, dynamic>> transfer({
    required String amount,
    required String currency,
    required String phoneNumber,
    required String payerMessage,
    required String payeeNote,
  }) async {
    print('Transfer method called but not implemented in backend...');

    return {
      'success': false,
      'message':
          'Transfer endpoint not available in the current backend implementation',
    };

    // Uncomment and modify this code when you add transfer endpoint to your backend:
    /*
    final requestBody = {
      'amount': amount,
      'currency': currency,
      'phoneNumber': phoneNumber,
      'payerMessage': payerMessage,
      'payeeNote': payeeNote,
      'environment': MtnMomoConfig.targetEnvironment,
    };

    try {
      final response = await http.post(
        Uri.parse('${MtnMomoConfig.baseUrl}/transfer'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return {
            'success': true,
            'referenceId': data['data']['referenceId'],
            'message': data['message'] ?? 'Transfer request sent successfully',
          };
        }
      }
      
      final errorData = json.decode(response.body);
      return {
        'success': false,
        'message': errorData['message'] ?? 'Transfer request failed',
        'error': errorData['error'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
    */
  }
}
