// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kampusmart2/models/user_role.dart';
import 'package:kampusmart2/screens/home_page.dart';
import 'package:kampusmart2/screens/notification_screen.dart';
import 'package:kampusmart2/widgets/layout1.dart';

class GuestWelcomeScreen extends StatefulWidget {
  static const String routeName = '/Guest';
  const GuestWelcomeScreen({super.key});

  @override
  State<GuestWelcomeScreen> createState() => _GuestWelcomeScreenState();
}

class _GuestWelcomeScreenState extends State<GuestWelcomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  DateTime? _selectedDate;
  bool _isButtonEnabled = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF26313A),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
        _checkFields();
      });
    }
  }

  void _checkFields() {
    setState(() {
      _isButtonEnabled = _nameController.text.isNotEmpty && _dobController.text.isNotEmpty;
    });
  }

  void _navigateToHome() {
    if (_isButtonEnabled) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(userRole: UserRole.buyer),
        ),
      );
    }
  }

  void _navigateToSignIn() {
    Navigator.pushReplacementNamed(context, '/Signup');
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_checkFields);
    _dobController.addListener(_checkFields);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE9A1),
      body: Stack(
        children: [
          // Top yellow background
          Container(
            color: const Color(0xFFFFE9A1),
          ),
          // Use Layout1 for the bottom section
          Align(
            alignment: Alignment.bottomCenter,
            child: Layout1(
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back arrow
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 16),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
                        onPressed: _navigateToSignIn,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Welcome message
                    const Padding(
                      padding: EdgeInsets.only(left: 24, top: 8),
                      child: Text(
                        'Welcome. we are happy to have you',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD09B5A), // Tertiary orange
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Form section
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _GuestInputField(
                              controller: _nameController,
                              hintText: 'enter your name Guest',
                            ),
                            const SizedBox(height: 24),
                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: AbsorbPointer(
                                child: _GuestInputField(
                                  controller: _dobController,
                                  hintText: 'enter your date of birth (dd/mm/yyyy)',
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isButtonEnabled ? _navigateToHome : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isButtonEnabled 
                                      ? const Color(0xFFD09B5A)
                                      : const Color(0xFFD09B5A).withOpacity(0.5),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text(
                                  'Continue',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuestInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  const _GuestInputField({required this.controller, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(
          fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}