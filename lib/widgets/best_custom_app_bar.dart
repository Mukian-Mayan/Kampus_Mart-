import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';

class BestCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final double height;
  final List<Color>? gradientColors;
  final Widget? bottomChild;
  final double borderRadius;
  final double elevation;

  const BestCustomAppBar({
    Key? key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.height = 160,
    this.gradientColors,
    this.bottomChild,
    this.borderRadius = 32,
    this.elevation = 0,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      color: Colors.transparent,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(borderRadius),
        bottomRight: Radius.circular(borderRadius),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradientColors != null
              ? LinearGradient(
                  colors: gradientColors!,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: gradientColors == null ? AppTheme.tertiaryOrange : null,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(borderRadius),
            bottomRight: Radius.circular(borderRadius),
          ),
          // No boxShadow for zero elevation
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    leading ?? const SizedBox(width: 40),
                    Expanded(
                      child: Center(
                        child: Text(
                          title,
                          style: AppTheme.titleStyle.copyWith(fontSize: 28, letterSpacing: 1),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    trailing ?? const SizedBox(width: 40),
                  ],
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Center(
                      child: Text(
                        subtitle!,
                        style: AppTheme.subtitleStyle.copyWith(fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                if (bottomChild != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 18.0),
                    child: bottomChild,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 