// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';

class ProfilePicWidget extends StatelessWidget {
  final String? imageUrl; // null if no image
  final VoidCallback? onAddPressed;
  final double radius;
  final double height;
  final double width;

  const ProfilePicWidget({
    super.key,
    this.imageUrl,
    this.onAddPressed,
    required this.radius, // default radius
    required this.height, // default height
    required this.width, // default width
  });

  @override
  Widget build(BuildContext context) {
    final alreadyHasAnImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        SizedBox(
          height: height,
          width: width,
          child: CircleAvatar(
            radius: radius,
            backgroundColor: AppTheme.borderGrey.withOpacity(0.9),
            backgroundImage: alreadyHasAnImage
                ? NetworkImage(imageUrl!)
                : const AssetImage('assets/default_profile.png')
                      as ImageProvider,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 4,
          child: GestureDetector(
            onTap: onAddPressed,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.borderGrey.withOpacity(0.4),
              child: const Icon(
                Icons.camera_alt,
                size: 18,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
