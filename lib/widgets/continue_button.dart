// widgets/generic_continue_button.dart
import 'package:flutter/material.dart';
import '../Theme/app_theme.dart';

class GenericContinueButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const GenericContinueButton({
    super.key,
    required this.onPressed,
    this.text = 'Continue',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.secondaryOrange,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 2,
        ),
        child: Text(
          text,
          style: AppTheme.buttonTextStyle.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}