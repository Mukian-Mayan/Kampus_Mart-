import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';
import 'package:kampusmart2/widgets/circle_design.dart';

class Layout3 extends StatelessWidget {
  const Layout3({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: screenWidth,
        height: 450,
        child: Stack(
          children: [
            // Grey Circles
            Positioned(
              top: 30,
              left: 20,
              child: CircleDesign(baseSize: 60),
            ),
            Positioned(
              top: 100,
              left: 140,
              child: CircleDesign(baseSize: 40),
            ),

            // 🔵 NEW: Left-side additional circle for balance
            Positioned(
              top: 220,
              left: 1,
              child: CircleDesign(baseSize: 30),
            ),

            // Orange Circles
            Positioned(
              top: 50,
              right: 20,
              child: CircleDesign(baseSize: 60),
            ),
            Positioned(
              top: 230,
              right: 140,
              child: CircleDesign(baseSize: 10),
            ),

            // Blue/Extra Circles
            Positioned(
              bottom: 0,
              left: screenWidth * 0.1,
              child: CircleDesign(baseSize: 20),
            ),
            Positioned(
              bottom: 150,
              left: screenWidth * 0.5,
              child: CircleDesign(baseSize: 50),
            ),
          
          ],
        ),
      ),
    );
  }
}
