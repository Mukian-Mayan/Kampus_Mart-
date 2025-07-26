import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';

class Layout2 extends StatelessWidget {
  final Widget? child;
  const Layout2({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.2,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                boxShadow: [BoxShadow(color: AppTheme.taleBlack, offset: Offset(5, 5), blurRadius: 10)],
                color: AppTheme.lightGrey,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(0),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(100),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only( bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.taleBlack,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0),
                  topRight: Radius.circular(0),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(100),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only( bottom: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0),
                  topRight: Radius.circular(0),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(100),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only( bottom: 40),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.deepBlue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0),
                  topRight: Radius.circular(0),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(100),
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
