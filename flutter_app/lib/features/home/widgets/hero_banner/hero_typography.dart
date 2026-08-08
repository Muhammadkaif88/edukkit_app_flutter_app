import 'package:flutter/material.dart';

/// Production-Grade Centralized Typography Helper for Hero Banner System.
/// Matches exact reference image typography proportions: Bold Title, Ultra-Compact Tagline, Small Badge & Button.
class HeroTypography {
  HeroTypography._();

  /// Title font size: 18sp (≤340dp), 19sp (341-360dp), 20sp (361-390dp), 21.5sp (391-430dp), 23sp (>430dp / Tablet)
  static double title(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    if (width <= 340) {
      return 18.0;
    } else if (width <= 360) {
      return 19.0;
    } else if (width <= 390) {
      return 20.0;
    } else if (width <= 430) {
      return 21.5;
    } else {
      return 23.0;
    }
  }

  /// Ultra-Compact Tagline/Subtitle font size: 8.5sp (≤340dp), 9sp (341-360dp), 9.5sp (361-390dp), 10sp (391-430dp), 10.5sp (>430dp / Tablet)
  static double subtitle(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    if (width <= 340) {
      return 8.5;
    } else if (width <= 360) {
      return 9.0;
    } else if (width <= 390) {
      return 9.5;
    } else if (width <= 430) {
      return 10.0;
    } else {
      return 10.5;
    }
  }

  /// Compact CTA Button font size: 9.5sp (≤360dp), 10.5sp (>360dp)
  static double button(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    if (width <= 360) {
      return 9.5;
    } else {
      return 10.5;
    }
  }

  /// Ultra-Compact Badge Pill font size: 7.5sp
  static double badge(BuildContext context) {
    return 7.5;
  }
}
