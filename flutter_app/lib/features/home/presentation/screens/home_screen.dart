import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../../../shared/widgets/widgets.dart';
import '../widgets/widgets.dart';

/// Modular, Production-Ready Edukkit HomeScreen
/// Composed strictly from independent, reusable feature widgets.
/// Supports Android phones, Large phones, Tablets, & Desktop displays via ResponsiveLayout.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey _communityBannerKey = GlobalKey();
  bool _isCommunityBannerVisible = false;

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis == Axis.vertical) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkCommunityBannerVisibility();
      });
    }
    return false;
  }

  void _checkCommunityBannerVisibility() {
    if (!mounted) return;
    final renderObject = _communityBannerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderObject != null && renderObject.attached) {
      final position = renderObject.localToGlobal(Offset.zero);
      final screenHeight = MediaQuery.of(context).size.height;
      final bannerHeight = renderObject.size.height;

      // Detect if Community Banner is in the visible screen viewport
      final isVisible = position.dy < (screenHeight - 60) && (position.dy + bannerHeight) > 80;

      if (isVisible != _isCommunityBannerVisible) {
        setState(() {
          _isCommunityBannerVisible = isVisible;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(activeRoute: '/home'),
      body: Stack(
        children: [
          ResponsiveLayout(
            builder: (context, helper) {
              return NotificationListener<ScrollNotification>(
                onNotification: _onScrollNotification,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // 1. App Header (HomeHeader)
                    const SliverToBoxAdapter(
                      child: HomeHeader(),
                    ),

                    // 2. Hero Banner Carousel Architecture Shell
                    const SliverToBoxAdapter(
                      child: HeroBannerCarousel(),
                    ),

                    const SliverToBoxAdapter(
                      child: AppSpacing.vGapSm,
                    ),

                    // 3. Category Section (Robotics, AI, IoT, Electronics, DIY Kits, Hardware Store)
                    const SliverToBoxAdapter(
                      child: CategorySection(),
                    ),

                    const SliverToBoxAdapter(
                      child: AppSpacing.vGapSm,
                    ),

                    // 4. Progress Card
                    const SliverToBoxAdapter(
                      child: ProgressCard(),
                    ),

                    const SliverToBoxAdapter(
                      child: AppSpacing.vGapSm,
                    ),

                    // 5. Featured Courses
                    const SliverToBoxAdapter(
                      child: FeaturedCourses(),
                    ),

                    const SliverToBoxAdapter(
                      child: AppSpacing.vGapSm,
                    ),

                    // 6. Weekly Challenge / Community Events
                    const SliverToBoxAdapter(
                      child: WeeklyChallenge(),
                    ),

                    const SliverToBoxAdapter(
                      child: SizedBox(height: 25.0),
                    ),

                    // 7. Join Our Community Banner (Step 1 Container Layout)
                    SliverToBoxAdapter(
                      child: JoinCommunityBanner(
                        key: _communityBannerKey,
                      ),
                    ),

                    // 8. Bottom Spacing
                    const SliverToBoxAdapter(
                      child: BottomSpacing(height: 20.0),
                    ),
                  ],
                ),
              );
            },
          ),

          // 8. Edukkit AI Floating Assistant Mascot (Hidden smoothly when Community Banner is in viewport)
          AiFloatingMascot(
            isHidden: _isCommunityBannerVisible,
          ),
        ],
      ),
    );
  }
}
