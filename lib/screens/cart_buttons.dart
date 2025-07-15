// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';

class CartButtons extends StatelessWidget {
  final Color fontColor;
  final double fontSize;
  final String text;
  final double containerWidth;
  final double containerHeight;
  final VoidCallback? onTap;

  const CartButtons({
    super.key,
    required this.fontColor,
    required this.fontSize,
    required this.text,
    required this.containerHeight,
    required this.containerWidth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(
          minHeight: containerHeight,
          minWidth: containerWidth,
        ),
        //height: containerHeight,
        //width: containerWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppTheme.coffeeBrown,
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: fontColor, fontSize: fontSize, fontWeight: FontWeight.w900, fontFamily: 'League Spartan'),
                ),
              ),
              
              ],
            
          ),
        ),
      ),
    );
  }
}
