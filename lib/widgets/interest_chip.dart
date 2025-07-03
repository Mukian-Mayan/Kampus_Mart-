import 'package:flutter/material.dart';
import '../models/interest_model.dart';
import '../Theme/app_theme.dart';
class InterestChip extends StatefulWidget {
  final Interest interest;
  final VoidCallback onTap;
  final int animationDelay;

  const InterestChip({
    super.key,
    required this.interest,
    required this.onTap,
    this.animationDelay = 0,
  });

  @override
  State<InterestChip> createState() => _InterestChipState();
}

class _InterestChipState extends State<InterestChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));
    
    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));
    
    // Delayed animation start
    Future.delayed(Duration(milliseconds: widget.animationDelay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: _buildChip(),
          ),
        );
      },
    );
  }

  Widget _buildChip() {
    return Semantics(
      label: '${widget.interest.name} interest',
      value: widget.interest.isSelected ? 'Selected' : 'Not selected',
      onTap: widget.onTap,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: AppTheme.selectedBlue.withOpacity(0.1),
          highlightColor: AppTheme.selectedBlue.withOpacity(0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: AppTheme.chipBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.interest.isSelected 
                    ? AppTheme.selectedBlue.withOpacity(0.3)
                    : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: widget.interest.isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.selectedBlue.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  _buildCheckbox(),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.interest.name,
                      style: AppTheme.chipTextStyle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: widget.interest.isSelected 
            ? AppTheme.selectedBlue 
            : Colors.white,
        border: Border.all(
          color: widget.interest.isSelected 
              ? AppTheme.selectedBlue 
              : AppTheme.borderGrey,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(3),
      ),
      child: widget.interest.isSelected
          ? const Icon(
              Icons.check,
              size: 14,
              color: Colors.white,
            )
          : null,
    );
  }
}