import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Presentation-only primitives for the premium Edukkit experience.
abstract final class AppColors {
  static const primary = Color(0xFF1976FF);
  static const secondary = Color(0xFF5B5FEF);
  static const accent = Color(0xFFFFC72C);
  static const background = Color(0xFFF8FAFC);
  static const card = Colors.white;
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const border = Color(0xFFE8EDF5);
}

abstract final class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 40.0;
}

abstract final class AppRadius {
  static const card = 24.0;
  static const control = 16.0;
  static const pill = 999.0;
}

abstract final class AppTypography {
  static TextStyle title(BuildContext context) => GoogleFonts.plusJakartaSans(
        color: AppColors.textPrimary,
        fontSize: 21,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      );

  static TextStyle body(BuildContext context) => GoogleFonts.plusJakartaSans(
        color: AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      );
}

class PremiumCard extends StatelessWidget {
  const PremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
    this.color = AppColors.card,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Ink(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: .08),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
