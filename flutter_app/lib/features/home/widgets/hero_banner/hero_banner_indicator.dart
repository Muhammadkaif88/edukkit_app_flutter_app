import 'package:flutter/material.dart';

/// Reusable Page Indicator for Hero Banner Carousel
class HeroBannerIndicator extends StatelessWidget {
  final int itemCount;
  final int currentIndex;
  final ValueChanged<int>? onDotTap;
  final Color activeColor;
  final Color inactiveColor;

  const HeroBannerIndicator({
    super.key,
    required this.itemCount,
    required this.currentIndex,
    this.onDotTap,
    this.activeColor = Colors.white,
    this.inactiveColor = const Color(0x66FFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    if (itemCount <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        final bool isActive = index == currentIndex;

        return GestureDetector(
          onTap: () => onDotTap?.call(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: isActive ? 18.0 : 6.0,
            height: 6.0,
            decoration: BoxDecoration(
              color: isActive ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}
