// Illustration_widget.dart
// ignore_for_file: file_names

import 'package:flutter/material.dart';

class IllustrationWidget extends StatelessWidget {
  const IllustrationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background decorative elements (optional - you can keep or remove these)
        Positioned(
          left: 40,
          top: 40,
          child: Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: 60,
          top: 30,
          child: _buildStar(8),
        ),
        Positioned(
          left: 60,
          top: 100,
          child: _buildStar(6),
        ),
        Positioned(
          right: 80,
          bottom: 60,
          child: _buildStar(10),
        ),
        Positioned(
          right: 40,
          bottom: 40,
          child: _buildCloud(),
        ),
        
        // Main illustration image
        Center(
          child: Image.asset(
            'lib/images/image2.png',
            width: MediaQuery.of(context).size.width * 0.8,
            fit: BoxFit.contain,
          ),
        ),
        
        // "the Rightseller" text removed as requested
      ],
    );
  }

  Widget _buildStar(double size) {
    return Icon(
      Icons.auto_awesome,
      color: Colors.white,
      size: size,
    );
  }

  Widget _buildCloud() {
    return Container(
      width: 35,
      height: 18,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}