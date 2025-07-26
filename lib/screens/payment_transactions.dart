import 'package:flutter/material.dart';
import 'package:kampusmart2/screens/payment_processing.dart';
import 'package:kampusmart2/momo_service.dart'; // Add this import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kampusmart2/models/cart_model.dart';
import 'package:kampusmart2/models/product.dart';
import 'package:kampusmart2/models/order.dart';
import 'package:kampusmart2/services/order_service.dart';
import 'package:kampusmart2/services/cart_service.dart';
import 'package:kampusmart2/services/product_service.dart';
import 'package:kampusmart2/services/notifications_service.dart';

class PaymentTransactions extends StatefulWidget {
  final double? totalAmount;
  final List<CartModel>? cartItems;
  final Map<String, Product>? productsMap;

  const PaymentTransactions({
    super.key,
    this.totalAmount,
    this.cartItems,
    this.productsMap,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentTransactions> {
  String selectedPaymentMethod = 'Payment on delivery';
  String selectedMobileMoneyProvider = '';
  final TextEditingController phoneController = TextEditingController();
  final CartService _cartService = CartService();

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
          // Total amount section
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Total amount due: UGX ${widget.totalAmount?.toStringAsFixed(0) ?? '0'}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          // Curved section with payment methods
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
                              ? const Color(0xFFE8A317)
                              : Colors.grey,
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
      // For cash on delivery, create order directly
      _createOrderAndNavigate();
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
        amount: (widget.totalAmount ?? 0).toStringAsFixed(
          0,
        ), // Convert to string as required by API
        currency: 'UGX', // Changed from EUR to UGX for Uganda
        phoneNumber: formattedPhone,
        payerMessage: 'Payment for Kampus Mart order',
        payeeNote:
            'Order payment - UGX ${(widget.totalAmount ?? 0).toStringAsFixed(0)}',
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
          '3. Confirm the payment of UGX ${(widget.totalAmount ?? 0).toStringAsFixed(0)}\n\n'
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
                    totalAmount: widget.totalAmount ?? 0.0,
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
                _createOrderAndNavigate();
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
        '3. Confirm the payment of UGX ${(widget.totalAmount ?? 0).toStringAsFixed(0)}\n\n'
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
              _createOrderAndNavigate();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<void> _createOrderAndNavigate() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _showPaymentError('Please log in to place an order');
      return;
    }

    if (widget.cartItems == null || widget.cartItems!.isEmpty) {
      _showPaymentError('No items in cart');
      return;
    }

    try {
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
              Text('Creating your order...'),
            ],
          ),
        ),
      );

      // Create the order
      await _createSingleOrder(currentUser, selectedPaymentMethod);

      // Complete the order process (update stock, clear cart, etc.)
      await _completeOrderProcess();

      Navigator.pop(context); // Close loading dialog

      // Navigate to payment processing screen with success
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentProcessingScreen(
            cartItems: [],
            totalAmount: widget.totalAmount ?? 0.0,
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showPaymentError('Failed to create order: $e');
    }
  }

  Future<Order> _createSingleOrder(
    User currentUser,
    String paymentMethod,
  ) async {
    // Group cart items by seller and take the first seller for now
    Map<String, List<CartModel>> itemsBySeller = {};
    for (var cartItem in widget.cartItems!) {
      final product = widget.productsMap?[cartItem.productId];
      if (product != null) {
        final sellerId = product.ownerId;
        if (!itemsBySeller.containsKey(sellerId)) {
          itemsBySeller[sellerId] = [];
        }
        itemsBySeller[sellerId]!.add(cartItem);
      }
    }

    // For now, create order with the first seller's items
    final firstSeller = itemsBySeller.entries.first;
    final sellerId = firstSeller.key;
    final sellerItems = firstSeller.value;

    // Convert cart items to order items
    List<OrderItem> orderItems = sellerItems.map((cartItem) {
      return OrderItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: cartItem.productId,
        productName: cartItem.productName,
        productImage: cartItem.productImage ?? '',
        price: cartItem.price,
        quantity: cartItem.quantity,
        subtotal: cartItem.price * cartItem.quantity,
      );
    }).toList();

    double subtotal = orderItems.fold(0.0, (sum, item) => sum + item.subtotal);
    double deliveryFee = 5000.0; // Fixed delivery fee

    // Create delivery address (placeholder)
    DeliveryAddress deliveryAddress = DeliveryAddress(
      street: 'Default Street',
      city: 'Kampala',
      state: 'Central',
      postalCode: '00000',
      country: 'Uganda',
    );

    final order = await OrderService.createOrder(
      buyerId: currentUser.uid,
      name: currentUser.displayName ?? 'Customer',
      email: currentUser.email ?? '',
      phone: currentUser.phoneNumber ?? '',
      sellerId: sellerId,
      items: orderItems,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
      notes: 'Order placed from app',
    );

    return order;
  }

  Future<void> _completeOrderProcess() async {
    // Update product stock and send notifications
    for (var cartItem in widget.cartItems!) {
      final product = widget.productsMap?[cartItem.productId];
      if (product != null && product.stock != null) {
        final newStock = (product.stock! - cartItem.quantity)
            .clamp(0, double.infinity)
            .toInt();
        try {
          await ProductService.updateProductStockForOrder(
            productId: cartItem.productId,
            newStock: newStock,
          );

          // Send low stock alert if needed
          if (newStock <= 5 && newStock > 0) {
            await NotificationService.sendLowStockAlert(
              sellerId: product.ownerId,
              productName: cartItem.productName,
              remainingStock: newStock,
            );
          }
        } catch (e) {
          print('Error updating product stock: $e');
        }
      }
    }

    // Clear the cart
    await _cartService.clearCart();
  }
}
