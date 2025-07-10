// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class PaymentTransactions extends StatefulWidget {
  const PaymentTransactions({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentTransactions> {
  String selectedPaymentMethod = 'Payment on delivery';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6A8), // Light yellow background
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
              child: const Text(
                'Total amount due: Shs 52,000',
                style: TextStyle(
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
                    const Color(0xFFF5E6A8), // Light yellow
                    const Color(0xFFE8A317), // Orange
                    const Color(0xFF2C3E50), // Dark blue
                  ],
                  stops: const [0.0, 0.3, 0.7],
                ),
              ),
              child: Column(
                children: [
                  // Curved white section
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

                  // Choose Payment Method title
                  const Text(
                    'Choose Payment Method',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Payment method options
                  Expanded(
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
                          const SizedBox(height: 15),
                          _buildPaymentOption(
                            'Credit Card',
                            selectedPaymentMethod == 'Credit Card',
                          ),
                          const SizedBox(height: 15),
                          _buildPaymentOption(
                            'Other',
                            selectedPaymentMethod == 'Other',
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Add button
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle add button press
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE8A317),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Add',
                          style: TextStyle(
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
          });
        },
      ),
    );
  }
}

// Main app to test the payment screen
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payment Screen Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Using default font family (no custom fonts specified)
      ),
      home: const PaymentTransactions(),
      debugShowCheckedModeBanner: false,
    );
  }
}
