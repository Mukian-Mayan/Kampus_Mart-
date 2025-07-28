import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';

class Layout3 extends StatelessWidget {
  const Layout3({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: screenWidth,
        height: 450, // increased height to fit larger circles
        child: Stack(
          children: [
            // Grey Circles
            Positioned(
              top: 20,
              left: 30,
              child: Container(
                height: 120, // was 60
                width: 120,
                decoration: const BoxDecoration(
                  color: AppTheme.lightGrey,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 120,
              left: 100,
              child: Container(
                height: 45, // was 30
                width: 45,
                decoration: const BoxDecoration(
                  color: AppTheme.lightGrey,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Orange Circles
            Positioned(
              top: 60,
              right: 50,
              child: Container(
                height: 100, // was 80
                width: 100,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryOrange,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 200,
              right: 100,
              child: Container(
                height: 55, // was 40
                width: 55,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryOrange,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Blue Circles
            Positioned(
              bottom: 30,
              left: screenWidth * 0.2,
              child: Container(
                height: 170, // was 100
                width: 170,
                decoration: const BoxDecoration(
                  color: AppTheme.deepBlue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 60,
              left: screenWidth * 0.7,
              child: Container(
                height: 90, // was 50
                width: 90,
                decoration: const BoxDecoration(
                  color: AppTheme.deepBlue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
