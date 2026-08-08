import 'package:flutter/material.dart';

/// Edukkit Design System Animation Constants
/// Standardized curves and durations for UI transitions.
abstract class AppAnimation {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  static const Curve defaultCurve = Curves.easeInOutCubic;
  static const Curve bounce = Curves.elasticOut;
  static const Curve decelerate = Curves.decelerate;
}
