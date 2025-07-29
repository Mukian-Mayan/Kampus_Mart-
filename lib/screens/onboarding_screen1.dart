import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
              const Spacer(flex: 1),
              // Main content section
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    // Image section (moved to extreme right)
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          const Spacer(flex: 3),
                          Image.asset(
                            'lib/images/image3.png',
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 1),
                    // Text section below image
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Our smart system connects you Instantly to the best match',
                          style: GoogleFonts.nunito(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        // const SizedBox(height: 8),
                        // Text(
                        //   'Instantly to the best match',
                        //   style: GoogleFonts.nunito(
                        //     fontSize: 25,
                        //     fontWeight: FontWeight.w600,
                        //     color: Colors.black,
                        //     height: 1.3,
                        //   ),
                        //   textAlign: TextAlign.center,
                        // ),
                        const SizedBox(height: 8),
                        Text(
                          'Saving time and effort...',
                          style: GoogleFonts.dancingScript(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            height: 2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 1),
              // Button section
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
