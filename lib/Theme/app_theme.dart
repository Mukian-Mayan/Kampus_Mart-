
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui'; // Added for ImageFilter

class AppTheme {
  // Colors
  static const Color primaryOrange = Color(0xFFF5A623);
  static const Color secondaryOrange = Color(0xFFD4A574);
  static const Color chipBackground = Color(0xFFF2E6C7);
  static const Color selectedBlue = Color(0xFF2196F3);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color borderGrey = Color(0xFFBDBDBD);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color deepBlue = Color(0xFF203344);
  static const Color tertiaryOrange = Color(0xFFFFEAA9);
  static const Color paleWhite = Color(0xFFFCFCFC);
  static const Color taleBlack = Color(0xFF0E0C0A);
  static const Color deepOrange = Color(0xFFEEAE2A);
  static const Color suggestedTabBrown = Color(0xFF7B5B43); // Used for 'suggested for you' button
  static const Color lightGreen = Color(0xFF00F710);
  static const Color coffeeBrown = Color(0xFFC78E57);
  static const Color red = Color.fromARGB(255, 230, 3, 3);
  static const Color backgroundLavender = Color(0xFFF7F3FA); // Light lavender background

  // Text Styles
  static const TextStyle titleStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    height: 1.2,
    fontFamily: 'League Spartan',
  );

  static const TextStyle onboardingTitleStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    height: 1.2,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    color: textSecondary,
    height: 1.4,
  );

  static const TextStyle chipTextStyle = TextStyle(
    fontSize: 16,
    color: textPrimary,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle skipTextStyle = TextStyle(
    color: textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.orange,
      scaffoldBackgroundColor: primaryOrange,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryOrange,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  // Glassy effect theme for reuse
  static const double glassyBlurSigma = 18.0;
  static Color get glassyOrangeColor => tertiaryOrange.withOpacity(0.8);

  /// Returns a BackdropFilter + Container for glassy orange effect
  static Widget glassyOrangeBackdrop({required double height}) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: glassyBlurSigma, sigmaY: glassyBlurSigma),
      child: Container(
        height: height,
        color: glassyOrangeColor,
      ),
    );
  }
}