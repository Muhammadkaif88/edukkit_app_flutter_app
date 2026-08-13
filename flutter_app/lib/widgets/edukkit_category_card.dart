import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'edukkit_category_icon.dart';

/// Reusable Edukkit Premium Category Card.
/// Used in Courses Home ("Explore by Category") and Category views.
/// Features soft pastel background (or optional full background image),
/// white circular 3D icon container, bold category title, and course count.
class EdukkitCategoryCard extends StatelessWidget {
  final String categoryName;
  final String courseCountText;
  final String iconAsset;
  final Color backgroundColor;
  final Color accentColor;
  final VoidCallback onTap;
  final double width;
  final String? backgroundImage;

  const EdukkitCategoryCard({
    super.key,
    required this.categoryName,
    required this.courseCountText,
    required this.iconAsset,
    required this.backgroundColor,
    required this.accentColor,
    required this.onTap,
    this.width = 145.0,
    this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    const borderRadiusVal = 22.0;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadiusVal),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.18),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadiusVal),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. FULL CARD BACKGROUND IMAGE (If uploaded)
            if (backgroundImage != null && backgroundImage!.isNotEmpty) ...[
              if (backgroundImage!.startsWith('http://') ||
                  backgroundImage!.startsWith('https://'))
                Image.network(
                  backgroundImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                )
              else
                Image.asset(
                  backgroundImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              // Subtle gradient overlay for text readability over full artwork
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.25),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],

            // 2. CARD CONTENT (Icon + Title + Course Count) ON TOP
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(borderRadiusVal),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(borderRadiusVal),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 3D Icon in White Circular Container
                      EdukkitCategoryIcon(
                        iconAsset: iconAsset,
                        size: 60.0,
                        iconRatio: 0.88,
                        shadowColor: accentColor.withValues(alpha: 0.15),
                      ),

                      const SizedBox(height: 8),

                      // Category Title
                      Text(
                        categoryName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                      ),

                      const SizedBox(height: 2),

                      // Course Count Subtitle
                      Text(
                        courseCountText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
