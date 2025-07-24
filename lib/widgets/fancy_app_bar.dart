import 'package:flutter/material.dart';
import '../Theme/app_theme.dart';
import 'dart:ui'; // used for BackdropFilter

class FancyAppBar extends StatefulWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final String title;
  final double height;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;
  final Widget? customContent;
  final bool showTabs; //

  const FancyAppBar({
    Key? key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
    this.title = '',
    this.height = 160,
    this.onSearchTap,
    this.onNotificationTap,
    this.customContent,
    this.showTabs = true,
  }) : super(key: key);

  @override
  State<FancyAppBar> createState() => _FancyAppBarState();
}

class _FancyAppBarState extends State<FancyAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        child: Stack(
          children: [
            // Glassy blur background
            AppTheme.glassyOrangeBackdrop(height: widget.height),
            // Foreground content
            Container(
              height: widget.height,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                // No color here, handled by glassy background
              ),
              child: Column(
                children: [
                  widget.customContent ??
                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 4,
                            left: 16,
                            right: 16,
                            bottom: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (widget.onSearchTap != null)
                                IconButton(
                                  icon: const Icon(
                                    Icons.search,
                                    color: Colors.black87,
                                    size: 22,
                                  ),
                                  onPressed: widget.onSearchTap,
                                  padding: const EdgeInsets.all(6),
                                  constraints: const BoxConstraints(
                                    minWidth: 36,
                                    minHeight: 36,
                                  ),
                                ),
                              if (widget.onNotificationTap != null)
                                IconButton(
                                  icon: const Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.black87,
                                    size: 22,
                                  ),
                                  onPressed: widget.onNotificationTap,
                                  padding: const EdgeInsets.all(6),
                                  constraints: const BoxConstraints(
                                    minWidth: 36,
                                    minHeight: 36,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: widget.showTabs
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              height: 44,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(widget.tabs.length, (
                                  index,
                                ) {
                                  final isSelected =
                                      index == widget.selectedIndex;
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: Material(
                                        color: isSelected
                                            ? Colors.brown
                                            : Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          side: isSelected
                                              ? BorderSide.none
                                              : const BorderSide(
                                                  color: Colors.brown,
                                                  width: 2,
                                                ),
                                        ),
                                        child: InkWell(
                                          onTap: () =>
                                              widget.onTabChanged(index),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          child: Container(
                                            height: 40,
                                            alignment: Alignment.center,
                                            child: Text(
                                              widget.tabs[index],
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.brown,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
