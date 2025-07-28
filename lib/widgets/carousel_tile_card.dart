// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class CarouselTileCard extends StatelessWidget {
  final String leftImage;
  final String centerImage;
  final String rightImage;
  final void Function(String imagePath)? onImageTap;

  const CarouselTileCard({
    Key? key,
    required this.leftImage,
    required this.centerImage,
    required this.rightImage,
    this.onImageTap,
  }) : super(key: key);

  // Helper function to determine if image is a network URL or local asset
  Widget _buildImage(String imagePath, BoxFit fit) {
    // Check if the image path is a network URL (starts with http or https)
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[300],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.grey),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(
                Icons.error_outline,
                color: Colors.grey,
                size: 40,
              ),
            ),
          );
        },
      );
    } else {
      // Local asset
      return Image.asset(
        imagePath,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(
                Icons.error_outline,
                color: Colors.grey,
                size: 40,
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            // Left tile
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: onImageTap != null ? () => onImageTap!(leftImage) : null,
                child: Container(
                  height: 170, // Increased from 140
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildImage(leftImage, BoxFit.cover),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Center tile
            Expanded(
              flex: 4,
              child: GestureDetector(
                onTap: onImageTap != null ? () => onImageTap!(centerImage) : null,
                child: Container(
                  height: 230, // Increased from 200
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _buildImage(centerImage, BoxFit.cover),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Right tile
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: onImageTap != null ? () => onImageTap!(rightImage) : null,
                child: Container(
                  height: 170, // Increased from 140
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildImage(rightImage, BoxFit.cover),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
