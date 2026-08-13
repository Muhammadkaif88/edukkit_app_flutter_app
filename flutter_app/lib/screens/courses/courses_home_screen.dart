import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/course_model.dart';
import 'category_courses_screen.dart';
import 'all_categories_screen.dart';
import 'robotics_courses_screen.dart';
import 'electronics_courses_screen.dart';
import 'iot_courses_screen.dart';
import 'diy_kits_courses_screen.dart';
import 'course_detail_screen.dart';
import 'data/courses_data.dart';
import 'widgets/category_chip.dart';
import 'widgets/explore_category_tile.dart';
import 'widgets/featured_course_banner.dart';
import 'widgets/new_recommended_card.dart';
import 'widgets/popular_course_card.dart';

class CoursesHomeScreen extends StatefulWidget {
  const CoursesHomeScreen({super.key});

  @override
  State<CoursesHomeScreen> createState() => _CoursesHomeScreenState();
}

class _CoursesHomeScreenState extends State<CoursesHomeScreen> {
  String _selectedCategory = 'All';

  late CourseModel _featuredCourse;
  late List<CourseModel> _popularCourses;
  late List<CourseModel> _newAndRecommendedCourses;
  final Set<String> _bookmarkedCourseIds = {};

  @override
  void initState() {
    super.initState();
    _featuredCourse = CoursesData.featuredCourse;
    _popularCourses = List.from(CoursesData.popularCourses);
    _newAndRecommendedCourses = List.from(CoursesData.newAndRecommendedCourses);
  }

  void _onCategorySelected(String category) {
    if (category == 'All') {
      setState(() {
        _selectedCategory = 'All';
      });
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryCoursesScreen(
          categoryTitle: category,
        ),
      ),
    );
  }

  void _onViewAllTapped(String sectionName) {
    final cat = (_selectedCategory == 'All') ? 'Robotics' : _selectedCategory;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryCoursesScreen(
          categoryTitle: cat,
        ),
      ),
    );
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

  void _openSearch() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Opening course search (/search-courses)...',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1E293B),
      ),
    );
  }

  List<CourseModel> _filterList(List<CourseModel> list) {
    if (_selectedCategory == 'All') return list;
    return list.where((c) {
      if (_selectedCategory.startsWith('IoT')) return c.category == 'IoT';
      if (_selectedCategory == '3D Printing') return c.category == '3D Printing';
      return c.category.toLowerCase().contains(_selectedCategory.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredPopular = _filterList(_popularCourses);
    final filteredNew = _filterList(_newAndRecommendedCourses);

    final featuredCourseWithState = _featuredCourse.copyWith(
      isBookmarked: _bookmarkedCourseIds.contains(_featuredCourse.id),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // ── 1. Top Bar ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Courses',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Learn. Build. Innovate. 🚀',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),

                      // Circular Search Icon Button (Right side)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _openSearch,
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0C000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.search_rounded,
                              color: Color(0xFF1E293B),
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── 2. Category Filter Chips (Horizontal Scroll) ────────
                CategoryFilterChipsBar(
                  categories: CoursesData.filterCategories,
                  selectedCategory: _selectedCategory,
                  onCategorySelected: _onCategorySelected,
                ),

                const SizedBox(height: 20),

                // ── 3. Featured Course (Large Banner Card) ──────────────
                _buildSectionHeader(
                  title: 'Featured Course',
                  onViewAll: () => _onViewAllTapped('Featured Course'),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FeaturedCourseBanner(
                    course: featuredCourseWithState,
                    onStartCourse: () => _openCourseDetail(featuredCourseWithState),
                    onToggleBookmark: () => _toggleBookmark(featuredCourseWithState),
                  ),
                ),

                const SizedBox(height: 28),

                // ── 4. Popular Courses (Horizontal Scroll Cards) ────────
                _buildSectionHeader(
                  title: 'Popular Courses',
                  onViewAll: () => _onViewAllTapped('Popular Courses'),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 275,
                  child: filteredPopular.isEmpty
                      ? _buildEmptyState('No popular courses in this category.')
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: filteredPopular.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 14),
                          itemBuilder: (context, index) {
                            final course = filteredPopular[index].copyWith(
                              isBookmarked:
                                  _bookmarkedCourseIds.contains(filteredPopular[index].id),
                            );
                            return PopularCourseCard(
                              course: course,
                              onTap: () => _openCourseDetail(course),
                              onToggleBookmark: () => _toggleBookmark(course),
                            );
                          },
                        ),
                ),

                const SizedBox(height: 28),

                // ── 5. Explore by Category (Grid List / Cards) ──────────
                _buildSectionHeader(
                  title: 'Explore by Category',
                  onViewAll: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AllCategoriesScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 156,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: CoursesData.exploreCategories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final item = CoursesData.exploreCategories[index];
                      return ExploreCategoryTile(
                        categoryItem: item,
                        onTap: () {
                          Widget targetScreen;
                          switch (item.id) {
                            case 'robotics':
                              targetScreen = const RoboticsCoursesScreen();
                              break;
                            case 'electronics':
                              targetScreen = const ElectronicsCoursesScreen();
                              break;
                            case 'iot':
                              targetScreen = const IotCoursesScreen();
                              break;
                            case 'diy_kits':
                              targetScreen = const DiyKitsCoursesScreen();
                              break;
                            default:
                              targetScreen = CategoryCoursesScreen(
                                categoryTitle: item.title,
                              );
                              break;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => targetScreen),
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 28),

                // ── 6. New & Recommended (Horizontal Scroll Cards) ──────
                _buildSectionHeader(
                  title: 'New & Recommended',
                  onViewAll: () => _onViewAllTapped('New & Recommended'),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 245,
                  child: filteredNew.isEmpty
                      ? _buildEmptyState('No new courses in this category.')
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: filteredNew.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 14),
                          itemBuilder: (context, index) {
                            final course = filteredNew[index].copyWith(
                              isBookmarked:
                                  _bookmarkedCourseIds.contains(filteredNew[index].id),
                            );
                            return NewRecommendedCard(
                              course: course,
                              onTap: () => _openCourseDetail(course),
                              onToggleBookmark: () => _toggleBookmark(course),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onViewAll,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          InkWell(
            onTap: onViewAll,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                children: [
                  Text(
                    'View All',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF4F46E5),
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: Color(0xFF4F46E5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String text) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
