// widgets/onboarding_content.dart
import 'package:flutter/material.dart';
import '../Theme/app_theme.dart';

class OnboardingContent extends StatelessWidget {
  final String imagePath;
  final String description;

  const OnboardingContent({
    super.key,
    required this.imagePath,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            height: 250,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 40),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}