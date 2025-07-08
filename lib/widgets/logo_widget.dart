import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The "K" image (magnifying glass)
        Image.asset(
          'lib/images/logo.png', // your magnifying glass
          width: 100,
          height: 100,
        ),
        const SizedBox(width: 8),
        // The "MART" image
        Image.asset(
          'lib/images/mart.png', // your MART image
          width: 100,
          height: 50,
        ),
      ],
    );
  }
}
