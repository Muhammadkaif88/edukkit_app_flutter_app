import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../../../shared/shared.dart';

/// WeeklyChallenge Component for Edukkit Home Screen
/// Interactive prompt encouraging students to participate in hands-on weekly challenges.
class WeeklyChallenge extends StatelessWidget {
  final String title;
  final String subtitle;
  final int participantCount;
  final VoidCallback? onJoinTap;

  const WeeklyChallenge({
    super.key,
    this.title = 'Build an Obstacle Avoiding Robot 🤖',
    this.subtitle = 'Submit your project video & win Edukkit Hardware Badges!',
    this.participantCount = 142,
    this.onJoinTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenMarginHorizontal,
        vertical: AppSpacing.xs,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5D31D7), Color(0xFF7545F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppRadius.borderXxl,
          boxShadow: AppShadows.primaryGlow(const Color(0xFF5D31D7)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const AppBadge(
                  text: 'WEEKLY HARDWARE CHALLENGE',
                  icon: Icons.emoji_events_rounded,
                  backgroundColor: Color(0x33FFFFFF),
                  textColor: Colors.white,
                  iconColor: AppColors.accentYellow,
                ),
                const Spacer(),
                Text(
                  '$participantCount Joined',
                  style: AppTypography.badge.copyWith(color: Colors.white70),
                ),
              ],
            ),
            AppSpacing.vGapSm,
            Text(
              title,
              style: AppTypography.h2.copyWith(color: Colors.white),
            ),
            AppSpacing.vGapXxs,
            Text(
              subtitle,
              style: AppTypography.bodyMedium.copyWith(color: Colors.white70),
            ),
            AppSpacing.vGapMd,
            AppButton(
              label: 'Join Challenge Now',
              onTap: onJoinTap ?? () {},
              icon: Icons.arrow_forward_rounded,
              backgroundColor: Colors.white,
              textColor: const Color(0xFF5D31D7),
            ),
          ],
        ),
      ),
    );
  }
}
