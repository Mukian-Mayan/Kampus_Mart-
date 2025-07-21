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
    return Padding(
      padding: EdgeInsets.all(pad),
      child: SizedBox(
        height: height,
        width: width,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.tertiaryOrange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: const BorderSide(color: Colors.brown, width: 2),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.brown,
              fontSize: fontSize,
              fontFamily: 'TypoGraphica',
              //fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
