import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// BottomSpacing Component for Edukkit Home Screen
/// Provides standardized bottom padding to ensure contents clear bottom navigation bars smoothly.
class BottomSpacing extends StatelessWidget {
  final double height;

  const BottomSpacing({
    super.key,
    this.height = AppSpacing.xxl,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}
