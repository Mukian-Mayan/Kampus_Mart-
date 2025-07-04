import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/onboarding_screen.dart';
import 'screens/interest_screen.dart';
import 'screens/onboarding_screen1.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'Theme/app_theme.dart';
import 'screens/login_or_register_page.dart';

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
        '/': (context) => const SplashScreen(), // Splash screen (first)
        '/WelcomeScreen': (context) => const WelcomeScreen(), // Welcome screen (second)
        '/OnboardingScreen': (context) => const OnboardingScreen(), // Third screen
        '/FourthOnboardingScreen': (context) => const FourthOnboardingScreen(), // Fourth screen
        '/InterestsScreen': (context) => const InterestsScreen(), 
        '/Signup': (context) => const LoginOrRegisterPage (), 
        
      },
    );
  }
}