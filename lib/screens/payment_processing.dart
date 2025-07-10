import 'dart:ui';
import 'package:flutter/material.dart';
class PaymentProcessingScreen extends StatelessWidget {
  const PaymentProcessingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for demonstration
    final products = [
      {'name': 'Product 1', 'quantity': 'Quantity', 'amount': 'Amount'},
      {'name': 'Product 2', 'quantity': 'Quantity', 'amount': 'Amount'},
      {'name': 'Product 3', 'quantity': 'Quantity', 'amount': 'Amount'},
      {'name': 'Product 4', 'quantity': 'Quantity', 'amount': 'Amount'},
    ];

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
          'Payments',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            // Blurred card
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  // Blurred background
                  Container(
                    height: 320,
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
                      height: 320,
                      width: double.infinity,
                      color: Colors.transparent,
                    ),
                  ),
                  // Card content
                  Container(
                    height: 320,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Table header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('Product 1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Text('Quantity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Text('Amount', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Product rows
                        ...products.skip(1).map((product) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(product['name']!, style: const TextStyle(color: Colors.white)),
                              Text(product['quantity']!, style: const TextStyle(color: Colors.white)),
                              Text(product['amount']!, style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                        )),
                        const Spacer(),
                        // Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const [
                            Text(
                              'Total : ',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              '300,000 UGX',
                              style: TextStyle(
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
                            onPressed: () {},
                            child: const Text(
                              'Proceed with payment',
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
            const Spacer(),
            // Bottom navigation bar
            Container(
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFDE9A9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Icon(Icons.settings, size: 32, color: Colors.black87),
                  Icon(Icons.shopping_cart, size: 32, color: Colors.black87),
                  Icon(Icons.home, size: 32, color: Colors.black87),
                  Icon(Icons.chat_bubble_outline, size: 32, color: Colors.black87),
                  Icon(Icons.person, size: 32, color: Colors.black87),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}