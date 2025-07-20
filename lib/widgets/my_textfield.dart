import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final String hintText;
  final Color focusedColor;
  final Color enabledColor;
  final int? maxLength;
  Widget? prefix;

  MyTextField({
    super.key,
    required this.enabledColor,
    required this.focusedColor,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.maxLength,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15, top: 10),
        child: TextField(
          cursorColor: AppTheme.borderGrey,
          controller: controller,
          obscureText: obscureText,
          maxLength: maxLength,

          style: TextStyle(color: AppTheme.paleWhite, fontFamily: 'Birdy Script',),

          decoration: InputDecoration(
            prefixIcon: prefix,
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
              color: AppTheme.deepOrange, fontFamily: 'League Spartan'
            ),
            
          ),
        ),
      ),
    );
  }
}
