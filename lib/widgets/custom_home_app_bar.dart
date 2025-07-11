import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';

class CustomHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onNotification;
  final double height;
  final bool addBottomRadius;

  const CustomHomeAppBar({
    Key? key,
    this.title = 'HOME',
    this.onBack,
    this.onNotification,
    this.height = 140,
    this.addBottomRadius = true,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.tertiaryOrange,
        borderRadius: addBottomRadius
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              )
            : null,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary),
                  onPressed: onBack ?? () {},
                ),
              ),
              Center(
                child: Text(
                  title,
                  style: AppTheme.titleStyle,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.textPrimary),
                  onPressed: onNotification ?? () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 