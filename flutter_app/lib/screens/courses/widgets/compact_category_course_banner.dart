import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/course_model.dart';

/// Full-Banner Image Implementation for Compact Category Course Banner.
/// Adheres strictly to the Global Edukkit Banner Rule:
/// - 1. The banner is ONE COMPLETE IMAGE artwork.
/// - 2. Image fills the entire banner area (BoxFit.cover).
/// - 3. Clipped to rounded corners (BorderRadius.circular(20)).
/// - 4. NO Flutter text, NO gradient overlay, NO badges, NO extra cards.
/// - 5. ONLY the optional CTA button ("Explore Course →") placed on top at bottom-right.
class CompactCategoryCourseBanner extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onTap;
  final bool showCtaButton;

  const CompactCategoryCourseBanner({
    super.key,
    required this.course,
    required this.onTap,
    this.showCtaButton = true,
  });

  @override
  Widget build(BuildContext context) {
    const bannerRadius = 20.0;
    final imagePath = (course.assetPath != null && course.assetPath!.isNotEmpty)
        ? course.assetPath!
        : 'assets/images/home/course_robotics_student.png';

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        // Maintain responsive aspect ratio ≈ 2.1 : 1
        final calculatedHeight = availableWidth / 2.1;
        // Clamp height strictly between 160px and 190px on mobile screens
        final bannerHeight = calculatedHeight.clamp(160.0, 190.0);

        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: bannerHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(bannerRadius),
              color: const Color(0xFF0F172A),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(bannerRadius),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. FULL-BLEED COMPLETE ARTWORK IMAGE
                  Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/home/course_robotics_student.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: const Color(0xFF1E1B4B)),
                      );
                    },
                  ),

                  // 2. ONLY OPTIONAL CTA BUTTON ON TOP OF THE IMAGE AT BOTTOM-RIGHT
                  if (showCtaButton)
                    Positioned(
                      right: 14,
                      bottom: 14,
                      child: Material(
                        color: const Color(0xFF4F46E5), // Edukkit Primary Purple/Indigo
                        borderRadius: BorderRadius.circular(20),
                        elevation: 4,
                        shadowColor: const Color(0x404F46E5),
                        child: InkWell(
                          onTap: onTap,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Explore Course',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 15.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
