import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/featured_course_model.dart';

/// Premium Horizontal Card Component for Featured Courses Page.
/// Features a large integrated 3D visual artwork on the left, title,
/// description, Kit Included badge, Beginner badge, Rating, Lessons,
/// and an accent "Start Course →" button.
class FeaturedCourseCard extends StatelessWidget {
  final FeaturedCourseModel course;
  final VoidCallback onTap;

  const FeaturedCourseCard({
    super.key,
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        // Responsive left visual width for narrow screens (320px - 412px)
        final double visualWidth = cardWidth < 360 ? 112.0 : 126.0;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFF1F5F9),
              width: 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
              BoxShadow(
                color: Color(0x054F46E5),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                splashColor: const Color(0x104F46E5),
                highlightColor: Colors.transparent,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── 1. Integrated Large Visual Artwork Container ─────────
                      SizedBox(
                        width: visualWidth,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Soft background gradient matching Edukkit aesthetic
                            Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFEEF2FF),
                                    Color(0xFFE0E7FF),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),

                            // Soft decorative circle accent behind 3D artwork
                            Positioned(
                              top: -15,
                              left: -15,
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.45),
                                ),
                              ),
                            ),

                            // Course 3D Artwork Image
                            Image.asset(
                              course.imageAsset,
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: const Color(0xFF4F46E5),
                                child: const Center(
                                  child: Icon(
                                    Icons.school_rounded,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── 2. Course Details & Action Column (Right Side) ──────
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Badges Row ([Kit Included], [Beginner])
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      if (course.kitIncluded)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 7,
                                            vertical: 2.5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFECFDF5),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                              color: const Color(0xFFA7F3D0),
                                              width: 0.8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.inventory_2_rounded,
                                                size: 11,
                                                color: Color(0xFF059669),
                                              ),
                                              const SizedBox(width: 3),
                                              Text(
                                                'Kit Included',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(0xFF059669),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                      // Level Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 2.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF0F9FF),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                            color: const Color(0xFFBAE6FD),
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.bar_chart_rounded,
                                              size: 11,
                                              color: Color(0xFF0284C7),
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              course.level,
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF0284C7),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 6),

                                  // Course Title
                                  Text(
                                    course.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0F172A),
                                      letterSpacing: -0.3,
                                      height: 1.2,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  // Course Description
                                  Text(
                                    course.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF64748B),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // Bottom Row: Stats (Rating & Lessons) + Start Course Button
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Stats (Rating + Lesson Count)
                                  Flexible(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.star_rounded,
                                          size: 15,
                                          color: Color(0xFFF59E0B),
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          '${course.rating}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Text(
                                          '•',
                                          style: TextStyle(
                                            color: Color(0xFFCBD5E1),
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            '${course.lessonCount} Lessons',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF64748B),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 6),

                                  // Start Course Action Button
                                  Material(
                                    color: const Color(0xFF4F46E5),
                                    borderRadius: BorderRadius.circular(10),
                                    child: InkWell(
                                      onTap: onTap,
                                      borderRadius: BorderRadius.circular(10),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Start Course',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 3),
                                            const Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 13,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
