import 'package:flutter/material.dart';

/// Edukkit Design System Spacing Tokens
/// Standardized spacing units to maintain visual consistency across all screens.
abstract class AppSpacing {
  // Base Spacing Values
  static const double xxxs = 2.0;
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;

  // Screen Margins & Padding
  static const double screenMarginHorizontal = 16.0;
  static const double screenMarginVertical = 16.0;
  static const double cardPadding = 16.0;
  static const double cardPaddingCompact = 12.0;

  // Reusable SizedBox Vertical Helpers
  static const SizedBox vGapXxxs = SizedBox(height: xxxs);
  static const SizedBox vGapXxs = SizedBox(height: xxs);
  static const SizedBox vGapXs = SizedBox(height: xs);
  static const SizedBox vGapSm = SizedBox(height: sm);
  static const SizedBox vGapMd = SizedBox(height: md);
  static const SizedBox vGapLg = SizedBox(height: lg);
  static const SizedBox vGapXl = SizedBox(height: xl);
  static const SizedBox vGapXxl = SizedBox(height: xxl);

  // Reusable SizedBox Horizontal Helpers
  static const SizedBox hGapXxxs = SizedBox(width: xxxs);
  static const SizedBox hGapXxs = SizedBox(width: xxs);
  static const SizedBox hGapXs = SizedBox(width: xs);
  static const SizedBox hGapSm = SizedBox(width: sm);
  static const SizedBox hGapMd = SizedBox(width: md);
  static const SizedBox hGapLg = SizedBox(width: lg);
  static const SizedBox hGapXl = SizedBox(width: xl);
}
