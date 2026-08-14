import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/course_model.dart';
import '../../shared/widgets/edukkit_bottom_navigation_bar.dart';
import 'course_detail_screen.dart';
import 'data/courses_data.dart';
import 'widgets/new_recommended_card.dart';

/// Dedicated New & Recommended View All Screen for Edukkit.
/// Displays newly added and recommended courses in a full vertical list using the Edukkit design system.
class NewRecommendedCoursesScreen extends StatefulWidget {
  const NewRecommendedCoursesScreen({super.key});

  @override
  State<NewRecommendedCoursesScreen> createState() => _NewRecommendedCoursesScreenState();
}

class _NewRecommendedCoursesScreenState extends State<NewRecommendedCoursesScreen> {
  final int _currentNavIndex = 2; // Courses tab is active
  final Set<String> _bookmarkedCourseIds = {};
  late List<CourseModel> _newAndRecommendedCourses;

  @override
  void initState() {
    super.initState();
    _newAndRecommendedCourses = CoursesData.getNewAndRecommendedCourses();
  }

  void _onNavTap(int index) {
    if (index == _currentNavIndex) return;
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _toggleBookmark(CourseModel course) {
    final isBookmarked = _bookmarkedCourseIds.contains(course.id);
    setState(() {
      if (isBookmarked) {
        _bookmarkedCourseIds.remove(course.id);
      } else {
        _bookmarkedCourseIds.add(course.id);
      }
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isBookmarked ? Icons.bookmark_remove_rounded : Icons.bookmark_added_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              isBookmarked
                  ? 'Removed "${course.title}" from saved courses'
                  : 'Saved "${course.title}" to bookmarks!',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4F46E5),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  void _openCourseDetail(CourseModel course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CourseDetailScreen(course: course),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
                  bottom: 110, // Padding for floating bottom nav
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── TOP BAR (Back Arrow + Back text) ─────────────────
                    Row(
                      children: [
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

                    // ── HEADER TITLE & SUBTITLE ──────────────────────────
                    Text(
                      'New & Recommended',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Fresh courses and picks for your learning journey',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── VERTICAL COURSES LIST / EMPTY STATE ──────────────
                    if (_newAndRecommendedCourses.isEmpty)
                      _buildEmptyState()
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _newAndRecommendedCourses.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final rawCourse = _newAndRecommendedCourses[index];
                          final course = rawCourse.copyWith(
                            isBookmarked: _bookmarkedCourseIds.contains(rawCourse.id),
                          );
                          return NewRecommendedCard(
                            width: double.infinity,
                            course: course,
                            onTap: () => _openCourseDetail(course),
                            onToggleBookmark: () => _toggleBookmark(course),
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

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFEEF2FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.rocket_launch_outlined,
                size: 36,
                color: Color(0xFF4F46E5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No courses available yet',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Check back soon for new and recommended courses.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
