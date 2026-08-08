import 'package:flutter/material.dart';

/// Edukkit Design System Colors
/// Single source of truth for all application colors.
abstract class AppColors {
  // Brand / Primary Palette
  static const Color primary = Color(0xFF1976FF);
  static const Color primaryDark = Color(0xFF0F56C7);
  static const Color primaryLight = Color(0xFFEBF3FF);
  static const Color primaryGradientStart = Color(0xFF1976FF);
  static const Color primaryGradientEnd = Color(0xFF5B5FEF);

  // Secondary Palette
  static const Color secondary = Color(0xFF5B5FEF);
  static const Color secondaryLight = Color(0xFFEEF0FF);
  static const Color accent = Color(0xFFFF9500);
  static const Color accentYellow = Color(0xFFFFD700);

  // Category Theme Colors
  static const Color robotics = Color(0xFF5D31D7);
  static const Color ai = Color(0xFF0284C7);
  static const Color iot = Color(0xFF0891B2);
  static const Color electronics = Color(0xFFEA580C);
  static const Color diyKits = Color(0xFF059669);
  static const Color store = Color(0xFF7C3AED);

  // Neutral Palette
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);

  // Typography Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status & Feedback Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Overlay Gradients
  static const LinearGradient darkOverlayGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xC8000000),
      Color(0x61000000),
      Colors.transparent,
    ],
    stops: [0.0, 0.6, 1.0],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1976FF),
      Color(0xFF5B5FEF),
    ],
  );
}
