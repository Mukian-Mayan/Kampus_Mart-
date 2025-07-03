// splash_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../Theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _animationController.forward();
    
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/WelcomeScreen');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryOrange,
      body: Stack(
        children: [
          // Floating circles decoration
          Positioned(
            top: 100,
            right: 50,
            child: _buildFloatingCircle(20, Colors.white.withOpacity(0.3))),
          Positioned(
            top: 200,
            left: 40,
            child: _buildFloatingCircle(15, Colors.white.withOpacity(0.4))),
          Positioned(
            top: 400,
            right: 60,
            child: _buildFloatingCircle(25, Colors.white.withOpacity(0.3))),
          Positioned(
            bottom: 200,
            left: 50,
            child: _buildFloatingCircle(18, Colors.white.withOpacity(0.4))),
          Positioned(
            bottom: 100,
            right: 40,
            child: _buildFloatingCircle(22, Colors.white.withOpacity(0.3))),
          Positioned(
            bottom: 300,
            left: 80,
            child: _buildFloatingCircle(16, Colors.white.withOpacity(0.4))),
          
          // Main content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Combined logo image (logo + "mart" text)
                  Image.asset(
                    'lib/images/logo.png', // Your combined logo image
                    width: 200,
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(
                    width:120,
                    child:Image.asset(
                      'lib/images/mart.png',
                      width: 120,
                      height: 250,
                      fit: BoxFit.contain,) ,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}