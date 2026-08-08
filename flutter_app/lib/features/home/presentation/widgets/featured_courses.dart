import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/core.dart';

/// Data Model for Featured Courses (Admin Panel & Backend Ready)
class CourseModel {
  final String id;
  final String title;
  final String subtitle;
  final String image;
  final double rating;
  final int totalLessons;
  final int displayOrder;
  final bool isActive;
  final String targetRoute;

  const CourseModel({
    required this.id,
    required this.title,
    this.subtitle = '',
    required this.image,
    required this.rating,
    required this.totalLessons,
    this.displayOrder = 0,
    this.isActive = true,
    this.targetRoute = '/course-details',
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      image: json['image'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      totalLessons: json['totalLessons'] ?? 20,
      displayOrder: json['displayOrder'] ?? 0,
      isActive: json['isActive'] ?? true,
      targetRoute: json['targetRoute'] ?? '/course-details',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'image': image,
      'rating': rating,
      'totalLessons': totalLessons,
      'displayOrder': displayOrder,
      'isActive': isActive,
      'targetRoute': targetRoute,
    };
  }
}

/// FeaturedCourses Component for Edukkit Home Screen (Final Polish ✨)
/// Premium education-style horizontal carousel displaying masterclass courses with clean 1-line subtitles.
class FeaturedCourses extends StatelessWidget {
  final List<CourseModel>? courses;
  final void Function(CourseModel course)? onCourseTap;
  final VoidCallback? onSeeAllTap;

  const FeaturedCourses({
    super.key,
    this.courses,
    this.onCourseTap,
    this.onSeeAllTap,
  });

  static const List<CourseModel> defaultCourses = [
    CourseModel(
      id: 'c1',
      title: 'Junior Automation & Sensors Masterclass',
      subtitle: 'Learn automation with sensors & build real-world projects.',
      image: AppAssets.courseJuniorAutomation,
      rating: 4.9,
      totalLessons: 24,
      displayOrder: 1,
      targetRoute: '/course-details/c1',
    ),
    CourseModel(
      id: 'c2',
      title: 'IoT Home Automation with ESP32 & Cloud',
      subtitle: 'Build smart IoT home projects with ESP32 & Cloud.',
      image: AppAssets.courseIotHomeAutomation,
      rating: 4.8,
      totalLessons: 32,
      displayOrder: 2,
      targetRoute: '/course-details/c2',
    ),
    CourseModel(
      id: 'c3',
      title: 'Advanced Robotics & Autonomous Navigation',
      subtitle: 'Master autonomous navigation & robotics engineering.',
      image: AppAssets.courseAdvancedRobotics,
      rating: 5.0,
      totalLessons: 40,
      displayOrder: 3,
      targetRoute: '/course-details/c3',
    ),
  ];

  void _handleCourseTap(BuildContext context, CourseModel course) {
    if (onCourseTap != null) {
      onCourseTap!(course);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening ${course.title}...'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleSeeAllTap(BuildContext context) {
    if (onSeeAllTap != null) {
      onSeeAllTap!();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Opening Courses Catalog...'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeCourses = (courses ?? defaultCourses)
        .where((c) => c.isActive)
        .toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    if (activeCourses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. SECTION HEADER (Title, Subtitle & View All Action)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMarginHorizontal),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Featured Courses 🌟',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 19.0,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Top-rated interactive masterclasses',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),

              // View All Button
              InkWell(
                onTap: () => _handleSeeAllTap(context),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976FF).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFD1E5FF),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1976FF),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 13,
                        color: Color(0xFF1976FF),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 2. HORIZONTAL SCROLLING COURSE CARDS (Show 2 Cards equal width & height)
        SizedBox(
          height: 268,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMarginHorizontal),
            scrollDirection: Axis.horizontal,
            itemCount: activeCourses.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final course = activeCourses[index];
              return _buildCourseCard(context, course);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCourseCard(BuildContext context, CourseModel course) {
    final cardWidth = MediaQuery.of(context).size.width * 0.68;
    final clampedWidth = cardWidth.clamp(240.0, 290.0);

    return SizedBox(
      width: clampedWidth,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _handleCourseTap(context, course),
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TOP IMAGE SECTION WITH GRADIENT OVERLAY (Larger 152dp Height)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                    child: Container(
                      height: 152,
                      width: double.infinity,
                      color: const Color(0xFFF1F5F9),
                      child: _buildCourseImage(course.image),
                    ),
                  ),

                  // Subtle Bottom Gradient Transition Shadow (12dp fade)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.0),
                            Colors.black.withValues(alpha: 0.08),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // CARD CONTENT: TITLE, SUBTITLE & BOTTOM INFO ONLY
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // TITLE (Max 2 lines bold typography)
                          Text(
                            course.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.2,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // SUBTITLE (Max 1 line, 12sp medium grey)
                          if (course.subtitle.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              course.subtitle,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),

                      // BOTTOM INFO ROW: ONLY ⭐ Rating & 🎓 Total Lessons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ⭐ Rating
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                '⭐',
                                style: TextStyle(fontSize: 12.5),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${course.rating}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),

                          // 🎓 Total Lessons
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                '🎓',
                                style: TextStyle(fontSize: 12.5),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${course.totalLessons} Lessons',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                            ],
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
    );
  }

  Widget _buildCourseImage(String rawImagePath) {
    final trimmedPath = rawImagePath.trim();

    // 1. Network Image Support
    if (trimmedPath.startsWith('http://') || trimmedPath.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: trimmedPath,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(color: const Color(0xFFF1F5F9)),
        errorWidget: (context, url, error) => Image.asset(
          AppAssets.courseJuniorAutomation,
          fit: BoxFit.cover,
        ),
      );
    }

    // 2. Short Name or Custom Asset Path Resolution (e.g. 'junior_automation' -> 'assets/images/courses/junior_automation.png')
    final resolvedPath = trimmedPath.startsWith('assets/')
        ? trimmedPath
        : 'assets/images/courses/$trimmedPath${trimmedPath.contains('.') ? '' : '.png'}';

    return Image.asset(
      resolvedPath,
      fit: BoxFit.cover,
      errorBuilder: (ctx, err, stack) => Image.asset(
        AppAssets.courseJuniorAutomation,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Container(
          color: const Color(0xFFE2E8F0),
          child: const Center(
            child: Icon(Icons.school_rounded, color: Color(0xFF1976FF), size: 36),
          ),
        ),
      ),
    );
  }
}
