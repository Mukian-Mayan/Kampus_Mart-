import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/onboarding_screen.dart';
import 'screens/interest_screen.dart';
import 'screens/onboarding_screen1.dart';
import 'Theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Declutter & Discover',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const FourthOnboardingScreen(), // First screen (OnboardingScreen1)
        '/OnboardingScreen': (context) => const OnboardingScreen(), // Second screen
        '/InterestsScreen': (context) => const InterestsScreen(), // Third screen
      },
    );
  }
}