import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final String hintText;
  final Color focusedColor;
  final Color enabledColor;
  final int? maxLength;

  const MyTextField({
    super.key,
    required this.enabledColor,
    required this.focusedColor,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.only(left: 25.0, right: 25, top: 10),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          maxLength: maxLength,

          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontFamily: 'Birdy Script',),

          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: enabledColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: focusedColor),
            ),
            filled: true,
            fillColor: Colors.grey[600],

            hintText: hintText,
            hintStyle: TextStyle(
              color: AppTheme.coffeeBrown, fontFamily: 'League Spartan'
            ),
            
          ),
        ),
      ),
    );
  }
}
