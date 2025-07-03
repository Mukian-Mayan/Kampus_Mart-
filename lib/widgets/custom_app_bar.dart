import 'package:flutter/material.dart';
import '../Theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBackPressed;
  final VoidCallback onSkipPressed;

  const CustomAppBar({
    Key? key,
    required this.onBackPressed,
    required this.onSkipPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.primaryOrange,
      elevation: 0,
      leading: Semantics(
        label: 'Go back',
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
          onPressed: onBackPressed,
          splashRadius: 24,
        ),
      ),
      actions: [
        Semantics(
          label: 'Skip interest selection',
          child: TextButton(
            onPressed: onSkipPressed,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.textPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('skip', style: AppTheme.skipTextStyle),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

