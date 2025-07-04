import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';

class Layout1 extends StatelessWidget {
  final Widget? child;
  const Layout1({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppTheme.lightGrey,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(200),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(200),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.deepBlue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(200),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                  ),
                ),
              ),
            ),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}
