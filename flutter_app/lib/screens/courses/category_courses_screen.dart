import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/course_model.dart';
import '../../shared/widgets/edukkit_bottom_navigation_bar.dart';
import 'course_detail_screen.dart';
import 'data/courses_data.dart';
import 'widgets/compact_category_course_banner.dart';

/// Reusable Category Courses Page with Compact Banner Style.
/// Displays a compact header, search entry point, category-filtered courses list
/// with full-bleed compact promotional banners, and the global floating bottom navigation.
class CategoryCoursesScreen extends StatefulWidget {
  final String categoryTitle;
  final String? subtitle;

  const CategoryCoursesScreen({
    super.key,
    required this.categoryTitle,
    this.subtitle,
  });

  @override
  State<CategoryCoursesScreen> createState() => _CategoryCoursesScreenState();
}

class _CategoryCoursesScreenState extends State<CategoryCoursesScreen> {
  int _currentNavIndex = 2; // Courses tab is active

  String get _computedSubtitle {
    if (widget.subtitle != null && widget.subtitle!.isNotEmpty) {
      return widget.subtitle!;
    }
    final title = widget.categoryTitle.toLowerCase();
    if (title.contains('robot')) {
      return 'Build, experiment & master robotics';
    } else if (title.contains('electr')) {
      return 'Master circuits, components & PCB design';
    } else if (title.contains('ai')) {
      return 'Explore artificial intelligence & prompt engineering';
    } else if (title.contains('3d') || title.contains('print')) {
      return 'Create physical prototypes & 3D models';
    } else {
      return 'Build smart IoT devices & cloud connections';
    }
  }

  void _onNavTap(int index) {
    if (index == _currentNavIndex) return;
    setState(() => _currentNavIndex = index);
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (index == 2) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Switched to nav tab $index'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
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
    final courses = CoursesData.getCoursesByCategory(widget.categoryTitle);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light, clean Edukkit background
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // ── Scrollable Page Content ──────────────────────────────────
            Positioned.fill(
              child: ListView(
                padding: const EdgeInsets.only(
                  left: 18,
                  right: 18,
                  top: 12,
                  bottom: 100, // Bottom padding for floating navigation bar
                ),
                children: [
                  // 1. Compact Top Bar (Back Arrow + Title + Search Icon)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: () => Navigator.of(context).pop(),
                              borderRadius: BorderRadius.circular(12),
                              child: const Padding(
                                padding: EdgeInsets.all(6.0),
                                child: Icon(
                                  Icons.arrow_back_rounded,
                                  color: Color(0xFF0F172A),
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.categoryTitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      // Search Action Button
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0F000000),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF0F172A),
                            size: 20,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Search tapped'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 2. Compact Page Header (Title + Subtitle)
                  Text(
                    '${widget.categoryTitle} Courses',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _computedSubtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 3. Compact Promotional Course Banners List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: courses.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      return CompactCategoryCourseBanner(
                        course: course,
                        onTap: () => _openCourseDetail(course),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ── 4. Global Floating Edukkit Bottom Navigation Bar ────────
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
