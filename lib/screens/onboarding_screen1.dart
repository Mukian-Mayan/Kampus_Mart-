import 'package:flutter/material.dart';
import 'package:kampusmart2/screens/login_or_register_page.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/onboarding_content.dart';
import '../widgets/continue_button.dart';
import '../Theme/app_theme.dart';

class FourthOnboardingScreen extends StatelessWidget {
  static const String routeName = '/FourthOnboardingScreen';

  const FourthOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryOrange,
      appBar: CustomAppBar(
        onBackPressed: () =>
            Navigator.pushReplacementNamed(context, '/OnboardingScreen'),
        onSkipPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginOrRegisterPage()),
        ),

        appBarColor: AppTheme.primaryOrange,
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
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginOrRegisterPage(),
                      ),
                    );
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
