// ignore_for_file: use_build_context_synchronously, unused_element, no_leading_underscores_for_local_identifiers

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';
import 'package:kampusmart2/models/user_role.dart';
import 'package:kampusmart2/screens/notification_screen.dart';
import 'package:kampusmart2/services/notificaations_service.dart' hide NotificationsScreen, UserRole;
import 'package:kampusmart2/widgets/bottom_nav_bar.dart';


// Cart item model
class CartItem {
  final String name;
  final int quantity;
  final double price;
  final String? imageUrl;

  CartItem({
    required this.name,
    required this.quantity,
    required this.price,
    this.imageUrl,
  });

  double get totalPrice => price * quantity;
}

class PaymentProcessingScreen extends StatelessWidget {
  final List<CartItem> cartItems;
  final double totalAmount;
  final int currentNavIndex;

  const PaymentProcessingScreen({
    super.key,
    required this.cartItems,
    required this.totalAmount,
    this.currentNavIndex = 1, // Default to cart tab
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: const Text(
          'Payment Summary',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(userRole: UserRole.buyer, userId: '',),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  // Payment summary card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      children: [
                        // Blurred background
                        Container(
                          height: cartItems.length > 3 ? 400 : 320,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color.fromRGBO(202, 146, 83, 0.7),
                                Color.fromRGBO(202, 146, 83, 0.5),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            height: cartItems.length > 3 ? 400 : 320,
                            width: double.infinity,
                            color: Colors.transparent,
                          ),
                        ),
                        // Card content
                        Container(
                          height: cartItems.length > 3 ? 400 : 320,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Table header
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Product',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Qty',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Amount',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(color: Colors.white54, thickness: 1),
                              const SizedBox(height: 8),
                              // Product rows
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: cartItems.map((item) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              item.name,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              '${item.quantity}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              '${item.totalPrice.toStringAsFixed(0)} UGX',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )).toList(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Divider(color: Colors.white54, thickness: 1),
                              const SizedBox(height: 8),
                              // Total
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Text(
                                    'Total: ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    '${totalAmount.toStringAsFixed(0)} UGX',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 28,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Proceed button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFCA9253),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    elevation: 4,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  onPressed: () {
                                    _processPayment(context);
                                  },
                                  child: const Text(
                                    'Proceed with Payment',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Payment methods info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Methods',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We accept Mobile Money, Bank Transfer, and Cash on Delivery',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom navigation
          BottomNavBar(selectedIndex: currentNavIndex,navBarColor: AppTheme.tertiaryOrange),
        ],
      ),
    );
  }

  void _processPayment(BuildContext context) {
    // Show payment processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCA9253)),
              ),
              const SizedBox(height: 16),
              const Text(
                'Processing Payment...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Total: ${totalAmount.toStringAsFixed(0)} UGX',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      },
    );

    // Simulate payment processing
    NotificationService.sendPaymentSuccess(
  userId: 'current_user_id', // You need to pass the actual user ID here
  orderId: 'order_id', // Pass the actual order ID if available
  amount: totalAmount,
);
  void _showPaymentSuccess(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your order has been placed successfully.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Color(0xFFCA9253),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Example usage from CartPage:
/*
// In your cart page, when user clicks proceed to payment:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PaymentProcessingScreen(
      cartItems: [
        CartItem(name: 'MacBook Pro', quantity: 1, price: 2500000),
        CartItem(name: 'iPhone 14', quantity: 2, price: 1200000),
        CartItem(name: 'AirPods', quantity: 1, price: 300000),
      ],
      totalAmount: 5200000,
      currentNavIndex: 1, // Cart tab
    ),
  ),
);
*/
}