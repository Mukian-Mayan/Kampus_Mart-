import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';

class GlassContainer extends StatelessWidget {
  final double width;
  final double height;
  final Widget? child;
  final double borderRadius;
  final double blur;
  final Color color;
  final EdgeInsetsGeometry padding;

  const GlassContainer({
    super.key,
    this.width = 300,
    this.height = 200,
    this.child,
    this.borderRadius = 20.0,
    this.blur = 10.0,
    this.color = AppTheme.selectedBlue,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height*0.8,
          padding: padding,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(100),
              topRight: Radius.circular(100),
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(0),
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
