import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:kampusmart2/models/order.dart';
import 'package:kampusmart2/momo_service.dart';

class OrderPaymentScreen extends StatefulWidget {
  final Order order;
  final VoidCallback onPaymentSuccess;

  const OrderPaymentScreen({
    super.key,
    required this.order,
    required this.onPaymentSuccess,
  });

  @override
  _OrderPaymentScreenState createState() => _OrderPaymentScreenState();
}

class _OrderPaymentScreenState extends State<OrderPaymentScreen> {
  String selectedPaymentMethod = 'Cash on Delivery';
  String selectedMobileMoneyProvider = '';
  final TextEditingController phoneController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isProcessing = false;

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
      backgroundColor: const Color(0xFFF5E6A8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5E6A8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Payment',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Order summary section
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Total: ${widget.order.totalAmount.toStringAsFixed(0)} UGX',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Items: ${widget.order.totalItems}',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  Text(
                    'Seller: ${widget.order.sellerName}',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),

          // Payment methods section
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFF5E6A8),
                    const Color(0xFFE8A317),
                    const Color(0xFF2C3E50),
                  ],
                  stops: const [0.0, 0.3, 0.7],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(60),
                        bottomRight: Radius.circular(60),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  const Text(
                    'Choose Payment Method',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
                              'Cash on Delivery',
                              selectedPaymentMethod == 'Cash on Delivery',
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
                              'Bank Transfer',
                              selectedPaymentMethod == 'Bank Transfer',
                            ),
                            const SizedBox(height: 15),
                            _buildPaymentOption(
                              'Card Payment',
                              selectedPaymentMethod == 'Card Payment',
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
                        onPressed: _canProceed() && !_isProcessing
                            ? () => _processPayment()
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _canProceed() && !_isProcessing
                              ? const Color(0xFFE8A317)
                              : Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: _isProcessing
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                selectedPaymentMethod == 'Mobile Money'
                                    ? 'Pay Now'
                                    : 'Confirm Order',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
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
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        trailing: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            color: isSelected ? Colors.white : Colors.transparent,
          ),
          child: isSelected
              ? const Icon(Icons.check, size: 16, color: Color(0xFF2C3E50))
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
            color: Colors.white,
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
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: selectedMobileMoneyProvider == 'MTN'
              ? 'Enter phone number (e.g., 0772123456)'
              : selectedMobileMoneyProvider == 'Airtel'
              ? 'Enter Airtel number (e.g., 0702123456)'
              : 'Enter phone number',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.phone, color: Colors.white.withOpacity(0.7)),
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
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return cleanPhone.length >= 9 && cleanPhone.length <= 15;
  }

  void _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      if (selectedPaymentMethod == 'Mobile Money') {
        await _processMobileMoneyPayment();
      } else {
        await _processOtherPayment();
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _processMobileMoneyPayment() async {
    if (selectedMobileMoneyProvider == 'MTN') {
      await _processMTNPayment();
    } else {
      await _processAirtelPayment();
    }
  }

  Future<void> _processMTNPayment() async {
    try {
      String formattedPhone = _formatPhoneForAPI(phoneController.text);

      final result = await MtnMomoService.requestToPay(
        amount: widget.order.totalAmount.toStringAsFixed(0),
        currency: 'UGX',
        phoneNumber: formattedPhone,
        payerMessage: 'Payment for Kampus Mart order ${widget.order.id}',
        payeeNote:
            'Order payment - ${widget.order.totalAmount.toStringAsFixed(0)} UGX',
      );

      if (result['success']) {
        await _updateOrderWithPayment(
          selectedPaymentMethod,
          result['referenceId'],
        );
        _showMTNPaymentSuccess(result['referenceId']);
      } else {
        _showPaymentError(result['message']);
      }
    } catch (e) {
      _showPaymentError(
        'Network error: Please check your connection and try again.',
      );
    }
  }

  Future<void> _processAirtelPayment() async {
    // Simulate Airtel payment for now
    await Future.delayed(const Duration(seconds: 2));
    await _updateOrderWithPayment(
      selectedPaymentMethod,
      'AIRTEL_${DateTime.now().millisecondsSinceEpoch}',
    );
    _showPaymentSuccess('Airtel Money payment processed successfully!');
  }

  Future<void> _processOtherPayment() async {
    // For other payment methods, just update the order with the payment method
    await _updateOrderWithPayment(selectedPaymentMethod, null);
    _showPaymentSuccess('Order confirmed with $selectedPaymentMethod!');
  }

  Future<void> _updateOrderWithPayment(
    String paymentMethod,
    String? referenceId,
  ) async {
    // Update the order's payment method in Firestore
    await _firestore.collection('orders').doc(widget.order.id).update({
      'paymentMethod': paymentMethod,
      'updatedAt': DateTime.now().toIso8601String(),
      if (referenceId != null) 'paymentReference': referenceId,
    });
  }

  String _formatPhoneForAPI(String phone) {
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanPhone.startsWith('0')) {
      cleanPhone = '256' + cleanPhone.substring(1);
    } else if (!cleanPhone.startsWith('256')) {
      cleanPhone = '256' + cleanPhone;
    }

    return cleanPhone;
  }

  void _showMTNPaymentSuccess(String referenceId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Payment Request Sent'),
        content: Text(
          'A payment request has been sent to ${phoneController.text}.\n\n'
          'Reference ID: $referenceId\n\n'
          'Please:\n'
          '1. Check your phone for the payment prompt\n'
          '2. Enter your MTN Mobile Money PIN\n'
          '3. Confirm the payment of ${widget.order.totalAmount.toStringAsFixed(0)} UGX\n\n'
          'The payment will be verified automatically.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to cart
              widget.onPaymentSuccess(); // Callback to handle success
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showPaymentSuccess(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Payment Confirmed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to cart
              widget.onPaymentSuccess(); // Callback to handle success
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
        title: const Text('Payment Error'),
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
}
