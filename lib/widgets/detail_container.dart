// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';

class DetailContainer extends StatelessWidget {
  final Color fontColor;
  final double fontSize;
  final String text;
  //final double containerWidth;
  //final double containerHeight;
  final IconData? iconData;
  final VoidCallback? onTap;

  const DetailContainer({
    super.key,
    required this.fontColor,
    required this.fontSize,
    required this.text,
    //required this.containerHeight,
    //required this.containerWidth,
    required this.iconData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
      //padding: const EdgeInsets.all(15),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          width: MediaQuery.of(context).size.width*0.8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: AppTheme.suggestedTabBrown.withOpacity(0.8),
          ),
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: fontColor,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'KG Penmanship',
                  ),
                ),
              ),
              if (iconData != null) ...[
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Icon(iconData, color: fontColor, size: fontSize + 2),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
