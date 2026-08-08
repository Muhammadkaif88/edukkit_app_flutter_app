import 'package:flutter/material.dart';
import '../../core/core.dart';

/// Reusable Section Header widget with Title, optional Subtitle & Action button
class AppSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const AppSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: AppTypography.h2,
              ),
              if (subtitle != null) ...[
                AppSpacing.vGapXxs,
                Text(
                  subtitle!,
                  style: AppTypography.bodyMedium,
                ),
              ],
            ],
          ),
          if (actionLabel != null && onActionTap != null)
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                actionLabel!,
                style: AppTypography.label.copyWith(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}
