import 'package:flutter/material.dart';
import '../../core/core.dart';

/// Reusable Badge component for tags and chips
class AppBadge extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;

  const AppBadge({
    super.key,
    required this.text,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.surface.withValues(alpha: 0.22);
    final txtColor = textColor ?? AppColors.textOnPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxxs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.borderLg,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: iconColor ?? AppColors.accentYellow,
              size: 11,
            ),
            AppSpacing.hGapXxs,
          ],
          Text(
            text,
            style: AppTypography.badge.copyWith(color: txtColor),
          ),
        ],
      ),
    );
  }
}
