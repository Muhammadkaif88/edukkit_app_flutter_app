import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PremiumCourseGridCard extends StatelessWidget {
  const PremiumCourseGridCard({
    super.key,
    required this.title,
    required this.thumbnailUrl,
    required this.category,
    required this.onTap,
    this.localImagePath,
    this.badgeLabel,
    this.lessonCount = '12 lessons',
    this.progress = .35,
  });

  final String title;
  final String thumbnailUrl;
  final String category;
  final String lessonCount;
  final double progress;
  final VoidCallback onTap;
  final String? localImagePath;
  final String? badgeLabel;

  @override
  Widget build(BuildContext context) {
    final effectiveBadge = badgeLabel ?? category;
    final accent = _accentFor(effectiveBadge, category);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  localImagePath != null
                      ? Image.asset(localImagePath!, fit: BoxFit.cover)
                      : thumbnailUrl.isEmpty
                      ? _CoursePlaceholder(color: accent)
                      : CachedNetworkImage(
                          imageUrl: thumbnailUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => _CoursePlaceholder(color: accent),
                        ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _Badge(label: effectiveBadge, color: accent),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.25,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        lessonCount,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 5,
                            color: accent,
                            backgroundColor: accent.withValues(alpha: 0.15),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(progress * 100).round()}%',
                        style: TextStyle(
                          color: accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _accentFor(String badge, String cat) {
    final key = badge.isNotEmpty ? badge.toLowerCase() : cat.toLowerCase();
    switch (key) {
      case 'popular':
        return const Color(0xFF2563EB); // Blue
      case 'beginner':
        return const Color(0xFF0D9488); // Teal
      case 'advanced':
        return const Color(0xFF7C3AED); // Purple
      case 'new':
        return const Color(0xFFF97316); // Orange
      case 'robotics':
        return const Color(0xFF2563EB);
      case 'iot':
        return const Color(0xFF0D9488);
      case 'electronics':
        return const Color(0xFFF97316);
      default:
        return const Color(0xFF2563EB);
    }
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

class _CoursePlaceholder extends StatelessWidget {
  const _CoursePlaceholder({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: [color.withValues(alpha: .9), color.withValues(alpha: .45)]))),
      Image.asset('assets/images/home/course_robotics_student.png', fit: BoxFit.cover),
      DecoratedBox(decoration: BoxDecoration(color: color.withValues(alpha: .12))),
    ],
  );
}
