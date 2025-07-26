import 'package:flutter/material.dart';
import 'package:kampusmart2/screens/payment_processing.dart';
import 'package:kampusmart2/momo_service.dart';
import 'package:kampusmart2/theme/app_theme.dart';
import 'package:kampusmart2/widgets/layout2.dart'; // Add this import

class PaymentTransactions extends StatefulWidget {
  const PaymentTransactions({super.key});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentTransactions> {
  String selectedPaymentMethod = 'Payment on delivery';
  String selectedMobileMoneyProvider = '';
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    phoneController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.tertiaryOrange,
      appBar: AppBar(
        backgroundColor:AppTheme.deepBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.paleWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Payment',
          style: TextStyle(
            color: AppTheme.paleWhite,
            fontSize: 25 ,
            fontWeight: FontWeight.w900,
            fontFamily: 'KG Penmanship',
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Total amount section
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Layout2(
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 18,),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        //color: AppTheme.tertiaryOrange,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Text.rich(
                        TextSpan(
                          text: 'Total amount due: ',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: AppTheme.paleWhite,
                          ),
                          children: [
                            TextSpan(
                              text: 'Shs 52,000',
                              style: TextStyle(
                                color: AppTheme.lightGreen,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'KG Red Hands',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Curved section with payment methods
          Expanded(
            child: Column(
              children: [
                /*Container(
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(60),
                      bottomRight: Radius.circular(60),
                    ),
                  ),
                ), */
            
                const SizedBox(height: 40),
            
                const Text(
                  'Choose Payment Method',
                  style: TextStyle(
                    fontSize: 25,
                    //fontWeight: FontWeight.w600,
                    fontFamily: 'TypoGraphica',
                    color: AppTheme.taleBlack,
                  ),
                ),
            
                const SizedBox(height: 30),
            
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _buildPaymentOption(
                            'Payment on delivery',
                            selectedPaymentMethod == 'Payment on delivery',
                          ),
                          const SizedBox(height: 15),
                          _buildPaymentOption(
                            'Mobile Money',
                            selectedPaymentMethod == 'Mobile Money',
                          ),
            
                          if (selectedPaymentMethod == 'Mobile Money') ...[
                            const SizedBox(height: 20),
                            _buildMobileMoneyProviders(),
                            const SizedBox(height: 20),
                            _buildPhoneNumberInput(),
                          ],
            
                          const SizedBox(height: 15),
                          _buildPaymentOption(
                            'Other',
                            selectedPaymentMethod == 'Other',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _canProceed()
                          ? () => _processPayment()
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _canProceed()
                            ? AppTheme.deepOrange
                            : AppTheme.borderGrey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        selectedPaymentMethod == 'Mobile Money'
                            ? 'Pay Now'
                            : 'Add',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'KG Red Hands',
                          color: AppTheme.taleBlack,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String title, bool isSelected) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: AppTheme.deepBlue.withOpacity(0.8), width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.deepBlue,
          ),
        ),
        trailing: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.paleWhite, width: 2),
            color: isSelected ? AppTheme.deepBlue : Colors.transparent,
          ),
          child: isSelected
              ? const Icon(Icons.check, size: 20, color: AppTheme.lightGreen)
              : null,
        ),
        onTap: () {
          setState(() {
            selectedPaymentMethod = title;
            if (title != 'Mobile Money') {
              selectedMobileMoneyProvider = '';
              phoneController.clear();
            }
          });
        },
      ),
    );
  }

  Widget _buildMobileMoneyProviders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Mobile Money Provider:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'KG Red Hands',
            color: AppTheme.taleBlack,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildProviderOption(
                'MTN Mobile Money',
                'MTN',
                Colors.yellow,
                selectedMobileMoneyProvider == 'MTN',
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildProviderOption(
                'Airtel Money',
                'Airtel',
                Colors.red,
                selectedMobileMoneyProvider == 'Airtel',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProviderOption(
    String title,
    String provider,
    Color color,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMobileMoneyProvider = provider;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.2)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: const Icon(
                Icons.phone_android,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneNumberInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: TextField(
        controller: phoneController,
        keyboardType: TextInputType.phone,
        style: const TextStyle(
            fontFamily: 'KG Red Hands',
            color: AppTheme.taleBlack,),
        decoration: InputDecoration(
          hintText: selectedMobileMoneyProvider == 'MTN'
              ? 'Enter phone number (e.g., 0772123456)'
              : selectedMobileMoneyProvider == 'Airtel'
              ? 'Enter Airtel number (e.g., 0702123456)'
              : 'Enter phone number',
          hintStyle: TextStyle(
            fontFamily: 'KG Red Hands',
            color: AppTheme.taleBlack.withOpacity(0.7)),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.phone, color: AppTheme.taleBlack.withOpacity(0.7)),
        ),
      ),
    );
  }

  bool _canProceed() {
    if (selectedPaymentMethod == 'Mobile Money') {
      return selectedMobileMoneyProvider.isNotEmpty &&
          phoneController.text.isNotEmpty &&
          _isValidPhoneNumber(phoneController.text);
    }
    return true;
  }

  bool _isValidPhoneNumber(String phone) {
    // Remove any non-numeric characters
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    // Accept any phone number that has at least 9 digits and at most 15 digits
    // This covers most international phone number formats
    return cleanPhone.length >= 9 && cleanPhone.length <= 15;
  }

  void _processPayment() {
    if (selectedPaymentMethod == 'Mobile Money') {
      _processMobileMoneyPayment();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PaymentProcessingScreen(cartItems: [], totalAmount: 0.0),
        ),
      );
    }
  }

  // Updated method to use actual MTN MoMo API
  void _processMobileMoneyPayment() async {
    if (selectedMobileMoneyProvider == 'MTN') {
      await _processMTNPayment();
    } else {
      // Keep existing Airtel simulation for now
      _processAirtelPayment();
    }
  }

  Future<void> _processMTNPayment() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processing MTN MoMo payment...'),
            Text('Please wait...'),
          ],
        ),
      ),
    );

    try {
      // Format phone number for MTN API (should be in format 256XXXXXXXXX)
      String formattedPhone = _formatPhoneForAPI(phoneController.text);

      // Make actual MTN MoMo API call
      final result = await MtnMomoService.requestToPay(
        amount: '52000', // Convert to string as required by API
        currency: 'UGX', // Changed from EUR to UGX for Uganda
        phoneNumber: formattedPhone,
        payerMessage: 'Payment for Kampus Mart order',
        payeeNote: 'Order payment - Shs 52,000',
      );

      Navigator.pop(context); // Close loading dialog

      if (result['success']) {
        // Payment request sent successfully
        _showMTNPaymentSuccess(result['referenceId']);
      } else {
        // Payment request failed
        _showPaymentError(result['message']);
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showPaymentError(
        'Network error: Please check your connection and try again.',
      );
    }
  }

  String _formatPhoneForAPI(String phone) {
    // Remove any non-numeric characters
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    // Convert from local format (0XXXXXXXXX) to international (256XXXXXXXXX)
    if (cleanPhone.startsWith('0')) {
      cleanPhone = '256' + cleanPhone.substring(1);
    }
    // If it doesn't start with country code, assume it's a Ugandan number
    else if (!cleanPhone.startsWith('256')) {
      cleanPhone = '256' + cleanPhone;
    }

    return cleanPhone;
  }

  void _showMTNPaymentSuccess(String referenceId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Request Sent'),
        content: Text(
          'A payment request has been sent to ${phoneController.text}.\n\n'
          'Reference ID: $referenceId\n\n'
          'Please:\n'
          '1. Check your phone for the payment prompt\n'
          '2. Enter your MTN Mobile Money PIN\n'
          '3. Confirm the payment of Shs 52,000\n\n'
          'The payment will be verified automatically.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // You can add payment status checking here
              _checkPaymentStatus(referenceId);
            },
            child: const Text('Check Payment Status'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentProcessingScreen(
                    cartItems: [],
                    totalAmount: 52000.0,
                  ),
                ),
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showPaymentError(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Failed'),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Future<void> _checkPaymentStatus(String referenceId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Checking payment status...'),
          ],
        ),
      ),
    );

    try {
      final result = await MtnMomoService.checkPaymentStatus(referenceId);
      Navigator.pop(context); // Close loading dialog

      if (result['success']) {
        String status = result['status'];
        _showPaymentStatusResult(status, referenceId);
      } else {
        _showPaymentError(
          'Failed to check payment status: ${result['message']}',
        );
      }
    } catch (e) {
      Navigator.pop(context);
      _showPaymentError('Network error while checking status.');
    }
  }

  void _showPaymentStatusResult(String status, String referenceId) {
    String message;
    bool isSuccess = false;

    switch (status.toLowerCase()) {
      case 'successful':
        message = 'Payment completed successfully!';
        isSuccess = true;
        break;
      case 'pending':
        message =
            'Payment is still pending. Please complete the payment on your phone.';
        break;
      case 'failed':
        message = 'Payment failed. Please try again.';
        break;
      default:
        message = 'Payment status: $status';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isSuccess ? 'Payment Successful' : 'Payment Status'),
        content: Text('$message\n\nReference ID: $referenceId'),
        actions: [
          if (!isSuccess)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _checkPaymentStatus(referenceId); // Check again
              },
              child: const Text('Check Again'),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (isSuccess) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentProcessingScreen(
                      cartItems: [],
                      totalAmount: 52000.0,
                    ),
                  ),
                );
              }
            },
            child: Text(isSuccess ? 'Continue' : 'OK'),
          ),
        ],
      ),
    );
  }

  void _processAirtelPayment() {
    // Keep existing Airtel simulation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processing Airtel payment...'),
            SizedBox(height: 8),
            Text('Please check your phone for the payment prompt'),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context);
      _showAirtelPaymentInstructions();
    });
  }

  void _showAirtelPaymentInstructions() {
    String instructions =
        'A payment request has been sent to ${phoneController.text}.\n\n'
        'Please:\n'
        '1. Check your phone for the payment prompt\n'
        '2. Enter your Airtel Money PIN\n'
        '3. Confirm the payment of Shs 52,000\n\n'
        'Or dial *185*9# and follow the prompts to complete payment.';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Airtel Money Payment'),
        content: Text(instructions),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentProcessingScreen(
                    cartItems: [],
                    totalAmount: 52000.0,
                  ),
                ),
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
