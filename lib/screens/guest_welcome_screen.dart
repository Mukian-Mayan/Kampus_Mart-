import 'package:flutter/material.dart';

class GuestWelcomeScreen extends StatefulWidget {
  const GuestWelcomeScreen({super.key});

  @override
  State<GuestWelcomeScreen> createState() => _GuestWelcomeScreenState();
}

class _GuestWelcomeScreenState extends State<GuestWelcomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

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
          // Curved white/yellow accent and dark section
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: _GuestCurveClipper(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.85,
                color: const Color(0xFF26313A),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back arrow
                const Padding(
                  padding: EdgeInsets.only(left: 16, top: 16),
                  child: Icon(Icons.arrow_back, color: Colors.black, size: 32),
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
                      color: Colors.black,
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
                        _GuestInputField(
                          controller: _dobController,
                          hintText: 'enter your date of birth',
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD09B5A),
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
      style: const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        filled: true,
        fillColor: const Color(0xFFE5E5E5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _GuestCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height * 0.18);
    path.quadraticBezierTo(
      size.width * 0.05, size.height * 0.10,
      size.width * 0.25, size.height * 0.10,
    );
    path.lineTo(size.width - 40, size.height * 0.10);
    path.quadraticBezierTo(
      size.width, size.height * 0.10,
      size.width, 0,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
} 