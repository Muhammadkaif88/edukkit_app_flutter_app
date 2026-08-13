import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/widgets/edukkit_bottom_navigation_bar.dart';
import 'category_courses_screen.dart';
import 'robotics_courses_screen.dart';
import 'electronics_courses_screen.dart';
import 'iot_courses_screen.dart';
import 'diy_kits_courses_screen.dart';

/// Data Architecture Model for Edukkit Categories Directory
class AllCategoryBannerItem {
  final String id;
  final String title;
  final String description;
  final String courseCountText;
  final String iconAsset;
  final Color backgroundColor;
  final Color accentColor;
  final Color pillBackgroundColor;
  final IconData pillIcon;
  final Widget Function(BuildContext context) targetScreenBuilder;

  const AllCategoryBannerItem({
    required this.id,
    required this.title,
    required this.description,
    required this.courseCountText,
    required this.iconAsset,
    required this.backgroundColor,
    required this.accentColor,
    required this.pillBackgroundColor,
    required this.pillIcon,
    required this.targetScreenBuilder,
  });
}

/// Edukkit "All Categories" Directory Screen
/// Premium EdTech learning domains directory matching exact reference design.
class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({super.key});

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  static const int _currentNavIndex = 2; // Courses tab active

  static final List<AllCategoryBannerItem> _categories = [
    AllCategoryBannerItem(
      id: 'robotics',
      title: 'Robotics',
      description:
          'Design, build and code robots. Learn sensors, motors and real-world automation.',
      courseCountText: '3 Courses',
      iconAsset: 'assets/icons/category_robotics.png',
      backgroundColor: const Color(0xFFF4F0FF),
      accentColor: const Color(0xFF7C3AED),
      pillBackgroundColor: const Color(0xFFE9D5FF),
      pillIcon: Icons.menu_book_rounded,
      targetScreenBuilder: (context) => const RoboticsCoursesScreen(),
    ),
    AllCategoryBannerItem(
      id: 'electronics',
      title: 'Electronics',
      description:
          'Explore circuits, components and build exciting electronic projects from scratch.',
      courseCountText: '3 Courses',
      iconAsset: 'assets/icons/category_electronics.png',
      backgroundColor: const Color(0xFFFFF4E6),
      accentColor: const Color(0xFFEA580C),
      pillBackgroundColor: const Color(0xFFFED7AA),
      pillIcon: Icons.bolt_rounded,
      targetScreenBuilder: (context) => const ElectronicsCoursesScreen(),
    ),
    AllCategoryBannerItem(
      id: 'ai',
      title: 'AI',
      description:
          'Learn Artificial Intelligence and Machine Learning with hands-on projects.',
      courseCountText: '2 Courses',
      iconAsset: 'assets/icons/category_ai.png',
      backgroundColor: const Color(0xFFEBF8FF),
      accentColor: const Color(0xFF0284C7),
      pillBackgroundColor: const Color(0xFFBAE6FD),
      pillIcon: Icons.auto_awesome_rounded,
      targetScreenBuilder: (context) => const CategoryCoursesScreen(
        categoryTitle: 'AI',
        subtitle: 'Learn AI and Machine Learning with hands-on projects',
      ),
    ),
    AllCategoryBannerItem(
      id: '3d_printing',
      title: '3D Printing',
      description:
          'Design in 3D and print your ideas. Learn modeling and prototype like a pro.',
      courseCountText: '2 Courses',
      iconAsset: 'assets/icons/category_3d_printing.png',
      backgroundColor: const Color(0xFFFDF2F8),
      accentColor: const Color(0xFFDB2777),
      pillBackgroundColor: const Color(0xFFFBCFE8),
      pillIcon: Icons.view_in_ar_rounded,
      targetScreenBuilder: (context) => const CategoryCoursesScreen(
        categoryTitle: '3D Printing',
        subtitle: 'Design in 3D and prototype like a pro',
      ),
    ),
    AllCategoryBannerItem(
      id: 'iot',
      title: 'IoT & Smart',
      description:
          'Connect devices, collect data and build smart IoT solutions for the real world.',
      courseCountText: '2 Courses',
      iconAsset: 'assets/icons/category_iot.png',
      backgroundColor: const Color(0xFFE6FFFA),
      accentColor: const Color(0xFF0D9488),
      pillBackgroundColor: const Color(0xFF99F6E4),
      pillIcon: Icons.sensors_rounded,
      targetScreenBuilder: (context) => const IotCoursesScreen(),
    ),
    AllCategoryBannerItem(
      id: 'diy_kits',
      title: 'DIY Kits',
      description:
          'Hands-on DIY kits for students. Build, learn and create amazing projects.',
      courseCountText: '2 Courses',
      iconAsset: 'assets/icons/category_diy_kits.png',
      backgroundColor: const Color(0xFFEDFDF2),
      accentColor: const Color(0xFF16A34A),
      pillBackgroundColor: const Color(0xFFBBF7D0),
      pillIcon: Icons.build_rounded,
      targetScreenBuilder: (context) => const DiyKitsCoursesScreen(),
    ),
  ];

  void _onNavTap(int index) {
    if (index == _currentNavIndex) return;
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _openCategory(AllCategoryBannerItem category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => category.targetScreenBuilder(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light #F8FAFC background
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // ── 1. Scrollable Main Content ──────────────────────────────
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // ── HEADER SECTION ──────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          // Compact Back Arrow Button
                          Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              onTap: () => Navigator.maybePop(context),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFF1F5F9),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.chevron_left_rounded,
                                  size: 26,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 14),

                          // Header Titles
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Explore Categories',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Choose your learning path',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── TOP HERO BANNER ─────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildTopHeroBanner(),
                    ),

                    const SizedBox(height: 20),

                    // ── CATEGORIES BANNER CARDS LIST ────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _categories.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          return _buildCategoryBannerCard(category);
                        },
                      ),
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

  /// Top Hero Banner Section for All Categories Page
  Widget _buildTopHeroBanner() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEEF2FF),
            Color(0xFFE0E7FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFC7D2FE),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Decorative background light circle
            Positioned(
              right: -20,
              top: -30,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.50),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.stars_rounded,
                                size: 14,
                                color: Color(0xFF4F46E5),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'LEARNING DOMAINS',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF4F46E5),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Explore Our Learning Domains',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                            letterSpacing: -0.3,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Learn Robotics, Electronics, AI, IoT, 3D Printing and more.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF475569),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Hero Illustration / Icon stack preview
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: Center(
                      child: Image.asset(
                        'assets/icons/category_robotics.png',
                        width: 70,
                        height: 70,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                          Icons.auto_awesome_rounded,
                          size: 48,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Horizontal Large Banner Card Component for Categories
  Widget _buildCategoryBannerCard(AllCategoryBannerItem category) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        // Calculate right side width for 3D illustration & arrow button
        final double rightAssetSpace = cardWidth < 360 ? 135.0 : 155.0;

        return Container(
          height: 148,
          decoration: BoxDecoration(
            color: category.backgroundColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: category.accentColor.withValues(alpha: 0.18),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: category.accentColor.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Soft Decorative Background Circle Behind 3D Icon
                Positioned(
                  right: 20,
                  top: -12,
                  bottom: -12,
                  width: 160,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.42),
                    ),
                  ),
                ),

                // 2. Large Custom 3D Category Illustration
                Positioned(
                  right: 44,
                  top: 10,
                  bottom: 10,
                  width: 125,
                  child: Center(
                    child: Image.asset(
                      category.iconAsset,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        category.pillIcon,
                        size: 64,
                        color: category.accentColor,
                      ),
                    ),
                  ),
                ),

                // 3. Small White Circular Arrow Button
                Positioned(
                  right: 14,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),

                // 4. Category Details Column (Left Side)
                Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    top: 12,
                    bottom: 12,
                    right: rightAssetSpace,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Category Title
                      Text(
                        category.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),

                      const SizedBox(height: 3),

                      // Short Description
                      Text(
                        category.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF475569),
                          height: 1.25,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Course Count Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: category.pillBackgroundColor.withValues(
                            alpha: 0.70,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              category.pillIcon,
                              size: 12,
                              color: category.accentColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              category.courseCountText,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: category.accentColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 5. Entire Card InkWell Touch Target
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => _openCategory(category),
                    splashColor: category.accentColor.withValues(alpha: 0.10),
                    highlightColor: Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
