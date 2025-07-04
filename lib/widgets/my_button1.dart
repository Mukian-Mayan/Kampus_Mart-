import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';

class MyButton1 extends StatelessWidget {
  final double height;
  final double width;
  final double pad;
  final double fontSize;
  final String text;
  final void Function()? onTap;
  //final double fontWeight;

  const MyButton1({
    super.key,
    required this.height,
    required this.width,
    required this.fontSize,
    required this.text,
    required this.onTap,
    required this.pad,
    //required this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: AppTheme.coffeeBrown,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(text,
              style: TextStyle(
                color: AppTheme.paleWhite,
                fontSize: fontSize,
                fontFamily: 'TypoGraphica',
                //fontFamily: 'League Spartan',
                //fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
