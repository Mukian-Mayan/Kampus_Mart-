import 'package:flutter/material.dart';
import 'shimmer_loading.dart';

class CarouselLoading extends StatelessWidget {
  const CarouselLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: ShimmerLoading(
              width: MediaQuery.of(context).size.width * 0.4,
              height: 180,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: ShimmerLoading(
              width: MediaQuery.of(context).size.width * 0.6,
              height: 180,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: ShimmerLoading(
              width: MediaQuery.of(context).size.width * 0.4,
              height: 180,
            ),
          ),
        ],
      ),
    );
  }
} 