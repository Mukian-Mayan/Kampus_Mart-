import 'package:flutter/material.dart';

/// A SliverPersistentHeaderDelegate that wraps the FancyAppBar widget.
class FancyAppBarSliverDelegate extends SliverPersistentHeaderDelegate {
  final double _minExtent;
  final double _maxExtent;
  final Widget Function(BuildContext context, double shrinkOffset, bool overlapsContent) builder;

  FancyAppBarSliverDelegate({
    required double minExtent,
    required double maxExtent,
    required this.builder,
  })  : _minExtent = minExtent,
        _maxExtent = maxExtent;

  @override
  double get minExtent => _minExtent;

  @override
  double get maxExtent => _maxExtent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return builder(context, shrinkOffset, overlapsContent);
  }

  @override
  bool shouldRebuild(covariant FancyAppBarSliverDelegate oldDelegate) {
    return _minExtent != oldDelegate._minExtent ||
        _maxExtent != oldDelegate._maxExtent ||
        builder != oldDelegate.builder;
  }
} 