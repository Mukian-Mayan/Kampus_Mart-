import 'package:flutter/material.dart';
import '../Theme/app_theme.dart';
import 'shimmer_loading.dart';

class ProductCardLoading extends StatelessWidget {
  const ProductCardLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.paleWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          const ShimmerLoading(
            width: double.infinity,
            height: 180,
            borderRadius: 0,
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name placeholder
                ShimmerLoading(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: 16,
                ),
                const SizedBox(height: 8),
                // Price placeholder
                ShimmerLoading(
                  width: MediaQuery.of(context).size.width * 0.25,
                  height: 14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 