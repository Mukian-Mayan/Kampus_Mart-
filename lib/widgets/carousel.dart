import 'dart:async';
import 'package:flutter/material.dart';

class Carousel extends StatefulWidget {
  final List<Widget> items;
  final double height;
  final double borderRadius;
  final Duration autoScrollDuration;

  const Carousel({
    Key? key,
    required this.items,
    this.height = 150, // Increased from 200
    this.borderRadius = 30, // Increased from 16
    this.autoScrollDuration = const Duration(seconds: 3),
  }) : super(key: key);

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  late final PageController _controller;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.autoScrollDuration, (_) {
      if (widget.items.length <= 1) return;
      int nextPage = (_currentPage + 1) % widget.items.length;
      _controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: SizedBox(
            height: widget.height,
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.items.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
                _startAutoScroll();
              },
              itemBuilder: (context, index) => widget.items[index],
            ),
          ),
        ),
        const SizedBox(height: 16), // Increased spacing
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.items.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 12 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index ? Colors.brown : Colors.brown[200],
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}
