import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';

class MySquareTile extends StatelessWidget {
  final String imagePath;
  final Function()? onTap;
  const MySquareTile({super.key, required this.onTap, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          height: MediaQuery.of(context).size.width * 0.04,
          width: MediaQuery.of(context).size.width * 0.04,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            color: AppTheme.paleWhite,
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Image.asset(imagePath, height: 30, width: 30),
          ),
        ),
      ),
    );
  }
}
