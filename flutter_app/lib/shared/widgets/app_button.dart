import 'package:flutter/material.dart';
import '../../core/core.dart';

/// Reusable Button component adhering to Edukkit Design System
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.height = 44,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primary;
    final txtColor = textColor ?? AppColors.textOnPrimary;

    Widget buttonContent = GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.borderRound,
          boxShadow: AppShadows.primaryGlow(bgColor),
        ),
        child: Row(
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: AppTypography.button.copyWith(color: txtColor),
            ),
            if (icon != null) ...[
              AppSpacing.hGapXs,
              Icon(icon, color: txtColor, size: 14),
            ],
          ],
        ),
      ),
    );

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: buttonContent,
      );
    }

    return buttonContent;
  }
}
