import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String _signInRole = 'Buyer';
  String _signUpRole = 'Buyer';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE9A1),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Back arrow
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 16),
                child: Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
            const SizedBox(height: 8),
            // Logo and title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Large logo (replace with your own asset if available)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'QK',
                        style: TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          shadows: [
                            Shadow(
                              color: Colors.black.withAlpha((0.4 * 255).round()),
                              offset: const Offset(3, 4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'mart',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withAlpha((0.4 * 255).round()),
                                  offset: const Offset(2, 3),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Kampus mart',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black.withAlpha((0.7 * 255).round()),
                              shadows: [
                                Shadow(
                                  color: Colors.white.withAlpha((0.7 * 255).round()),
                                  offset: const Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'continue as',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Sign In button with dropdown
                  _RoleDropdownButton(
                    label: 'Sign In',
                    value: _signInRole,
                    onChanged: (val) => setState(() => _signInRole = val!),
                  ),
                  const SizedBox(height: 16),
                  // Sign Up button with dropdown
                  _RoleDropdownButton(
                    label: 'Sign Up',
                    value: _signUpRole,
                    onChanged: (val) => setState(() => _signUpRole = val!),
                  ),
                  const SizedBox(height: 16),
                  // Guest button (no dropdown)
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Guest',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            const Spacer(),
            // Illustration (replace with your own asset if available)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Image.asset(
                'assets/images/illustration.png',
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleDropdownButton extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String?> onChanged;
  const _RoleDropdownButton({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DropdownButtonHideUnderline(
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFD09B5A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: value,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            dropdownColor: const Color(0xFFD09B5A),
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            isExpanded: true,
            onChanged: onChanged,
            items: [
              DropdownMenuItem(
                value: 'Buyer',
                child: Text('$label as Buyer', style: const TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: 'Seller',
                child: Text('$label as Seller', style: const TextStyle(color: Colors.white)),
              ),
            ],
            selectedItemBuilder: (context) => [
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}