import 'package:flutter/material.dart';
import 'package:kampusmart2/screens/payment_processing.dart';

class PaymentTransactions extends StatefulWidget {
  const PaymentTransactions({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentTransactions> {
  String selectedPaymentMethod = 'Payment on delivery';
  String selectedMobileMoneyProvider = '';
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Listen to changes in the phone number field
    phoneController.addListener(() {
      setState(() {
        // This will trigger a rebuild when the text changes
      });
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

                            // Mobile Money providers section
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

                  // Add button
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
              ? 'Enter MTN number (e.g., 0772123456)'
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
    // Basic validation for Ugandan phone numbers
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (selectedMobileMoneyProvider == 'MTN') {
      // MTN numbers start with 077, 078, 039
      return cleanPhone.length == 10 &&
          (cleanPhone.startsWith('077') ||
              cleanPhone.startsWith('078') ||
              cleanPhone.startsWith('039'));
    } else if (selectedMobileMoneyProvider == 'Airtel') {
      // Airtel numbers start with 070, 075, 020
      return cleanPhone.length == 10 &&
          (cleanPhone.startsWith('070') ||
              cleanPhone.startsWith('075') ||
              cleanPhone.startsWith('020'));
    }

    return false;
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

  void _processMobileMoneyPayment() {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Processing $selectedMobileMoneyProvider payment...'),
            const SizedBox(height: 8),
            const Text('Please check your phone for the payment prompt'),
          ],
        ),
      ),
    );

    // Simulate payment processing
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context); // Close loading dialog

      // Show payment instructions
      _showPaymentInstructions();
    });
  }

  void _showPaymentInstructions() {
    String instructions = '';
    String shortCode = '';

    if (selectedMobileMoneyProvider == 'MTN') {
      shortCode = '*165*3#';
      instructions =
          'A payment request has been sent to ${phoneController.text}.\n\n'
          'Please:\n'
          '1. Check your phone for the payment prompt\n'
          '2. Enter your MTN Mobile Money PIN\n'
          '3. Confirm the payment of Shs 52,000\n\n'
          'Or dial $shortCode and follow the prompts to complete payment.';
    } else if (selectedMobileMoneyProvider == 'Airtel') {
      shortCode = '*185*9#';
      instructions =
          'A payment request has been sent to ${phoneController.text}.\n\n'
          'Please:\n'
          '1. Check your phone for the payment prompt\n'
          '2. Enter your Airtel Money PIN\n'
          '3. Confirm the payment of Shs 52,000\n\n'
          'Or dial $shortCode and follow the prompts to complete payment.';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$selectedMobileMoneyProvider Payment'),
        content: Text(instructions),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to payment processing screen
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
