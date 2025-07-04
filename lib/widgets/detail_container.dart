// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';

class DetailContainer extends StatelessWidget {
  final Color fontColor;
  final double fontSize;
  final String text;
  final double containerWidth;
  final double containerHeight;
  final IconData? iconData;
  final Function()? onTap;

  const DetailContainer({
    super.key,
    required this.fontColor,
    required this.fontSize,
    required this.text,
    required this.containerHeight,
    required this.containerWidth,
    required this.iconData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: containerHeight,
          width: containerWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppTheme.borderGrey.withOpacity(0.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 8),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: fontColor, fontSize: fontSize),
                ),
                if (iconData != null) ...[
                  Icon(iconData, color: fontColor, size: fontSize + 2),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
