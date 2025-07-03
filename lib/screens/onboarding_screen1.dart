// screens/onboarding_screen1.dart
import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/onboarding_content.dart';
import '../widgets/continue_button.dart';
import '../Theme/app_theme.dart';

class FourthOnboardingScreen extends StatelessWidget {
  static const String routeName = '/';

  final VoidCallback? onBackPressed;
  final VoidCallback? onContinuePressed;

  const FourthOnboardingScreen({
    super.key,
    this.onBackPressed,
    this.onContinuePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryOrange,
      appBar: CustomAppBar(
        onBackPressed: onBackPressed ?? () => Navigator.pop(context),
        onSkipPressed: () => Navigator.pushNamed(context, '/InterestsScreen'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const OnboardingContent(
                imagePath: 'lib/images/image3.png',
                description: 
                  'Our smart system connects you instantly to the best match — saving time and effort.',
              ),
              const Spacer(flex: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: GenericContinueButton(
                  onPressed: onContinuePressed ?? () {
                    Navigator.pushNamed(context, '/OnboardingScreen');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}