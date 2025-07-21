import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';

class FancyAppBar extends StatefulWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final String title;
  final Widget? trailing;
  final double height;
  final double tabVisibility;
  final Widget? customContent;

  const FancyAppBar({
    Key? key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
    this.title = '',
    this.trailing,
    this.height = 160,
    this.tabVisibility = 1.0,
    this.customContent,
  }) : super(key: key);

  @override
  State<FancyAppBar> createState() => _FancyAppBarState();
}

class _FancyAppBarState extends State<FancyAppBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _pendingIndex = 0;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onTabChanged(_pendingIndex);
        setState(() {
          _isAnimating = false;
        });
        _controller.reset();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    if (index == widget.selectedIndex || _isAnimating) return;
    setState(() {
      _pendingIndex = index;
      _isAnimating = true;
    });
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    // Responsive values based on height
    final double minHeight = 80;
    final double maxHeight = 110;
    final double t = ((widget.height - minHeight) / (maxHeight - minHeight)).clamp(0.0, 1.0);
    final double titleOpacity = t;
    final double tabButtonHeight = 24 + 14 * t; // 24 at min, 38 at max
    final double tabButtonFontSize = 12 + 3 * t; // 12 at min, 15 at max
    final double tabButtonWidth = 120 + 80 * t; // 120 at min, 200 at max
    final double tabSpacing = 20 + 30 * t; // 20 at min, 50 at max
    final double cutoutHeight = tabButtonHeight + 10;
    final double cutoutWidth = tabButtonWidth + 16;
    final double cutoutHeightRow = tabButtonHeight + 35;

    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          double animT = _animation.value;
          bool flipping = _isAnimating;
          double angle = flipping ? animT * math.pi : 0;
          int displayIndex = (flipping && animT > 0.5) ? _pendingIndex : widget.selectedIndex;
          bool isLeft = displayIndex == 0;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Always-visible yellow background
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    height: widget.height,
                    decoration: BoxDecoration(
                      color: const Color(0x80FFE28A), // more transparent yellow
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),
              // Pill cutout (notch) always visible at full size when tabVisibility is 1.0
              LayoutBuilder(
                builder: (context, constraints) {
                  double totalWidth = constraints.maxWidth;
                  double buttonsTotalWidth = tabButtonWidth * widget.tabs.length + tabSpacing * (widget.tabs.length - 1);
                  double leftOffset = (totalWidth - buttonsTotalWidth) / 2;
                  double cutoutLeft;
                  if (isLeft) {
                    cutoutLeft = leftOffset + (tabButtonWidth - cutoutWidth) / 2;
                  } else {
                    cutoutLeft = leftOffset + tabButtonWidth + tabSpacing + (tabButtonWidth - cutoutWidth) / 2;
                  }
                  double animatedCutoutWidth = cutoutWidth;
                  double animatedCutoutHeight = cutoutHeight;
                  double animatedCutoutLeft = cutoutLeft;
                  if (widget.tabVisibility < 1.0) {
                    animatedCutoutWidth = cutoutWidth * widget.tabVisibility;
                    animatedCutoutHeight = cutoutHeight * widget.tabVisibility;
                    animatedCutoutLeft = isLeft
                        ? leftOffset + (tabButtonWidth - animatedCutoutWidth) / 2
                        : leftOffset + tabButtonWidth + tabSpacing + (tabButtonWidth - animatedCutoutWidth) / 2;
                  }
                  return AnimatedOpacity(
                    opacity: widget.tabVisibility,
                    duration: const Duration(milliseconds: 300),
                    child: ClipPath(
                      clipper: _AppbarWithNotchClipper(
                        cutoutLeft: animatedCutoutLeft,
                        cutoutWidth: animatedCutoutWidth,
                        cutoutHeight: animatedCutoutHeight,
                        isLeft: isLeft,
                      ),
                      child: Container(
                        height: widget.height,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFE28A),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              // AppBar content (icons and title)
              SafeArea(
                bottom: false,
                child: widget.customContent != null
                  ? Padding(
                      padding: EdgeInsets.only(left: 16 * t, right: 16 * t, top: 0, bottom: 0),
                      child: widget.customContent,
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 16 * t, right: 16 * t, top: 0, bottom: 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Center(
                                  child: Opacity(
                                    opacity: titleOpacity,
                                    child: Text(
                                      widget.title,
                                      style: TextStyle(fontSize: 24 * t + 12 * (1 - t), fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              if (widget.trailing != null) widget.trailing!,
                            ],
                          ),
                        ),
                      ],
                    ),
              ),
              // Tab buttons row (fixed, not rotating)
              Positioned(
                left: 0,
                right: 0,
                bottom: -12,
                child: AnimatedOpacity(
                  opacity: widget.tabVisibility,
                  duration: const Duration(milliseconds: 300),
                  child: AnimatedSlide(
                    offset: Offset(0, 0.2 * (1 - widget.tabVisibility)),
                    duration: const Duration(milliseconds: 300),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double totalWidth = constraints.maxWidth;
                        double buttonsTotalWidth = tabButtonWidth * widget.tabs.length + tabSpacing * (widget.tabs.length - 1);
                        double leftOffset = (totalWidth - buttonsTotalWidth) / 2;
                        int displayIndex = (flipping && animT > 0.5) ? _pendingIndex : widget.selectedIndex;
                        return SizedBox(
                          height: cutoutHeightRow,
                          child: Padding(
                            padding: EdgeInsets.only(left: leftOffset),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: List.generate(widget.tabs.length, (index) {
                                  final isSelected = index == displayIndex;
                                  return Padding(
                                    padding: EdgeInsets.only(right: index < widget.tabs.length - 1 ? tabSpacing : 0),
                                    child: GestureDetector(
                                      onTap: () => _onTabTap(index),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        width: tabButtonWidth,
                                        height: tabButtonHeight,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: isSelected ? Colors.brown : Colors.transparent,
                                          borderRadius: BorderRadius.circular(20),
                                          border: isSelected
                                              ? null
                                              : Border.all(color: Colors.brown, width: 2),
                                        ),
                                        child: Text(
                                          widget.tabs[index],
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : Colors.brown,
                                            fontWeight: FontWeight.bold,
                                            fontSize: tabButtonFontSize,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AppbarWithNotchClipper extends CustomClipper<Path> {
  final double cutoutLeft;
  final double cutoutWidth;
  final double cutoutHeight;
  final bool isLeft;
  _AppbarWithNotchClipper({required this.cutoutLeft, required this.cutoutWidth, required this.cutoutHeight, required this.isLeft});

  @override
  Path getClip(Size size) {
    Path path = Path();
    // Appbar outer shape
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - 20);
    path.quadraticBezierTo(size.width, size.height, size.width - 20, size.height);
    path.lineTo(20, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - 20);
    path.close();
    // Add the notch as a rounded rectangle (pill shape)
    Path notch = Path();
    notch.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(cutoutLeft, size.height - cutoutHeight, cutoutWidth, cutoutHeight),
      Radius.circular(cutoutHeight / 2),
    ));
    // Combine using evenOdd fill type
    path.addPath(notch, Offset.zero);
    path.fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
} 