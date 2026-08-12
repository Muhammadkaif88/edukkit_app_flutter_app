import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/course_model.dart';

/// Pure Image-Based Promotional Banner for Featured Course.
/// Treats the uploaded artwork image as the complete banner visual design.
/// Features a single floating "Explore Course →" CTA button overlay at the bottom-right.
class FeaturedCourseBanner extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onStartCourse;
  final VoidCallback? onToggleBookmark;

  const FeaturedCourseBanner({
    super.key,
    required this.course,
    required this.onStartCourse,
    this.onToggleBookmark,
  });

  @override
  Widget build(BuildContext context) {
    const bannerRadius = 20.0;
    final primaryImagePath = (course.assetPath != null && course.assetPath!.isNotEmpty)
        ? course.assetPath!
        : 'assets/images/home/course_robotics_student.png';

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        // Maintain design reference aspect ratio ≈ 1.85 : 1 (18.5 cm × 10 cm)
        final calculatedHeight = availableWidth / 1.85;
        // Reasonable responsive min/max constraints for mobile screens
        final bannerHeight = calculatedHeight.clamp(160.0, 240.0);

        return GestureDetector(
          onTap: onStartCourse,
          child: Container(
            width: double.infinity,
            height: bannerHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(bannerRadius),
              color: const Color(0xFFF1F5F9), // Light background placeholder
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
                    primaryImagePath,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/home/featured_course_banner_artwork.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/featured_course_banner_artwork.png',
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/home/course_robotics_student.png',
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildFallbackVisual(),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),

                  // 2. SINGLE FLOATING CTA OVERLAY BUTTON ("Explore Course →")
                  Positioned(
                    right: 14,
                    bottom: 14,
                    child: Material(
                      color: const Color(0xFF4F46E5), // Edukkit Indigo / Purple Accent
                      borderRadius: BorderRadius.circular(20),
                      elevation: 4,
                      shadowColor: const Color(0x404F46E5),
                      child: InkWell(
                        onTap: onStartCourse,
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

  Widget _buildFallbackVisual() {
    return Container(
      color: const Color(0xFF4F46E5),
      child: const Center(
        child: Icon(
          Icons.smart_toy_rounded,
          size: 64,
          color: Colors.white,
        ),
      ),
    );
  }
}
