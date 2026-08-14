import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/featured_course_model.dart';
import '../../shared/widgets/edukkit_bottom_navigation_bar.dart';
import 'course_detail_screen.dart';
import 'data/courses_data.dart';
import 'widgets/featured_course_card.dart';

/// Featured Courses "View All" Screen for Edukkit.
/// Displays ONLY currently approved featured courses in a vertical list,
/// preserving Edukkit design language, back navigation, and global bottom nav.
class FeaturedCoursesScreen extends StatefulWidget {
  const FeaturedCoursesScreen({super.key});

  @override
  State<FeaturedCoursesScreen> createState() => _FeaturedCoursesScreenState();
}

class _FeaturedCoursesScreenState extends State<FeaturedCoursesScreen> {
  final int _currentNavIndex = 2; // Courses tab is active

  void _onNavTap(int index) {
    if (index == _currentNavIndex) return;
    if (index == 0) {
      // Navigate back to home root shell
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _openCourseDetail(FeaturedCourseModel featuredCourse) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CourseDetailScreen(
          course: featuredCourse.toCourseModel(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final featuredCourses = CoursesData.getApprovedFeaturedCourses();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light Edukkit background
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // ── 1. Scrollable Main Page Content ──────────────────────────
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  left: 18,
                  right: 18,
                  top: 12,
                  bottom: 110, // Bottom padding for global floating navigation bar
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── TOP BAR (Back Arrow + Subtitle Header) ───────────
                    Row(
                      children: [
                        // Compact Back Arrow Button
                        Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFF1F5F9),
                                  width: 1.0,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x0A000000),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.chevron_left_rounded,
                                size: 26,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Back text button target for intuitive navigation
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Text(
                            'Back',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // ── PAGE HEADER TITLE & SUBTITLE ───────────────────────
                    Text(
                      'Featured Courses',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Top-rated interactive masterclasses',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── VERTICAL FEATURED COURSES LIST ─────────────────────
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: featuredCourses.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final course = featuredCourses[index];
                        return FeaturedCourseCard(
                          course: course,
                          onTap: () => _openCourseDetail(course),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ── 2. Global Floating Edukkit Bottom Navigation Bar ────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: EdukkitBottomNavigationBar(
                currentIndex: _currentNavIndex,
                onTap: _onNavTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
