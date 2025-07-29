import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';

class CircleDesign extends StatelessWidget {
  final Widget? child;
  final double baseSize;
  const CircleDesign({super.key, this.child, required this.baseSize});

  @override
  Widget build(BuildContext context) {
    //double baseSize = 200;
    double secondSize = baseSize * 0.86;
    double thirdSize = secondSize * 0.8;

    return Stack(
      alignment: Alignment.center,
      children: [
        // First circle - base
        Center(
          child: Container(
            width: baseSize,
            height: baseSize,
            decoration: const BoxDecoration(
              color: AppTheme.deepBlue,
              shape: BoxShape.circle,
            ),
          ),
        ),

        // Second circle - 10% smaller
        Center(
          child: Container(
            width: secondSize,
            height: secondSize,
            decoration: const BoxDecoration(
              color: AppTheme.paleWhite,
              shape: BoxShape.circle,
            ),
          ),
        ),

        // Third circle - another 10% smaller
        Center(
          child: Container(
            width: thirdSize,
            height: thirdSize,
            decoration: const BoxDecoration(
              color: AppTheme.deepOrange,
              shape: BoxShape.circle,
            ),
          ),
        ),

        // Optional child in center
        if (child != null)
          Center(child: child!),
      ],
    );
  }
}
