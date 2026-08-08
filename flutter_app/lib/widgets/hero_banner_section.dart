import 'dart:async';
import 'package:flutter/material.dart';

/// Model representing a single Hero Banner item
class HeroBannerModel {
  final String id;
  final String badge;
  final IconData? badgeIcon;
  final String titleLine1;
  final String titleLine2;
  final String subtitle;
  final String buttonText;
  final String imageAsset;
  final String? imageUrl;
  final Color buttonTextColor;
  final Color arrowBgColor;
  final Color indicatorColor;
  final String? actionUrl;
  final VoidCallback? onTap;

  const HeroBannerModel({
    required this.id,
    this.badge = 'New Arrival',
    this.badgeIcon = Icons.work_rounded,
    required this.titleLine1,
    required this.titleLine2,
    required this.subtitle,
    this.buttonText = 'Explore Kits Now',
    required this.imageAsset,
    this.imageUrl,
    this.buttonTextColor = const Color(0xFF5D31D7),
    this.arrowBgColor = const Color(0xFF5D31D7),
    this.indicatorColor = const Color(0xFF5D31D7),
    this.actionUrl,
    this.onTap,
  });

  /// Default Banners with 100% Full Background Image & Crisp Text Overlay
  static List<HeroBannerModel> defaultBanners = const [
    HeroBannerModel(
      id: 'diy_kits',
      badge: 'New Arrival',
      badgeIcon: Icons.work_rounded,
      titleLine1: 'Build. Create.',
      titleLine2: 'Explore DIY Kits.',
      subtitle: 'Hands-on kits for young innovators.\nBuild real projects. Learn by doing.',
      buttonText: 'Explore Kits Now',
      imageAsset: 'assets/images/home/banner_bg_diy_kits.png',
      buttonTextColor: Color(0xFF5D31D7),
      arrowBgColor: Color(0xFF5D31D7),
      indicatorColor: Color(0xFF5D31D7),
    ),
    HeroBannerModel(
      id: 'robotics',
      badge: 'Robotics',
      badgeIcon: Icons.smart_toy_rounded,
      titleLine1: 'Learn. Code.',
      titleLine2: 'Robotics Masterclass.',
      subtitle: 'Build sensors & mechanical parts.\nMaster robotics step by step.',
      buttonText: 'Start Course',
      imageAsset: 'assets/images/home/banner_bg_diy_kits.png',
      buttonTextColor: Color(0xFF0284C7),
      arrowBgColor: Color(0xFF0284C7),
      indicatorColor: Color(0xFF0284C7),
    ),
    HeroBannerModel(
      id: 'home_automation',
      badge: 'Smart Living',
      badgeIcon: Icons.home_rounded,
      titleLine1: 'Build. Automate.',
      titleLine2: 'Live Smarter.',
      subtitle: 'Explore Home Automation Kits and\ncontrol your world with technology.',
      buttonText: 'Explore Automation Kits',
      imageAsset: 'assets/images/home/banner_bg_diy_kits.png',
      buttonTextColor: Color(0xFF0891B2),
      arrowBgColor: Color(0xFF0891B2),
      indicatorColor: Color(0xFF06B6D4),
    ),
    HeroBannerModel(
      id: 'electronics',
      badge: 'Electronics 101',
      badgeIcon: Icons.bolt_rounded,
      titleLine1: 'Master. Circuits.',
      titleLine2: 'Hardware Logic.',
      subtitle: 'Hands-on PCB design and circuits.\nBuild the hardware of tomorrow.',
      buttonText: 'Get Started',
      imageAsset: 'assets/images/home/banner_bg_diy_kits.png',
      buttonTextColor: Color(0xFFEA580C),
      arrowBgColor: Color(0xFFEA580C),
      indicatorColor: Color(0xFFEA580C),
    ),
  ];
}

/// Premium Hero Banner Section with auto-scroll PageView and smooth indicator
class HeroBannerSection extends StatefulWidget {
  final List<HeroBannerModel>? banners;
  final Duration autoScrollDuration;

  const HeroBannerSection({
    super.key,
    this.banners,
    this.autoScrollDuration = const Duration(seconds: 4),
  });

  @override
  State<HeroBannerSection> createState() => _HeroBannerSectionState();
}

class _HeroBannerSectionState extends State<HeroBannerSection> {
  late final PageController _pageController;
  Timer? _autoScrollTimer;
  int _activePage = 0;

  List<HeroBannerModel> get _bannerList =>
      (widget.banners != null && widget.banners!.isNotEmpty)
          ? widget.banners!
          : HeroBannerModel.defaultBanners;

  @override
  void initState() {
    super.initState();
    _activePage = 1000 * _bannerList.length;
    _pageController = PageController(initialPage: _activePage);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(widget.autoScrollDuration, (_) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banners = _bannerList;
    final int realIndex = _activePage % banners.length;
    final activeColor = banners[realIndex].indicatorColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 180px Height Full Width Container with 12 Horizontal Margin
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _activePage = index;
              });
            },
            itemBuilder: (context, index) {
              final model = banners[index % banners.length];
              return HeroBannerCard(model: model);
            },
          ),
        ),
        const SizedBox(height: 10),
        // Animated Page Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            banners.length,
            (i) => AnimatedIndicator(
              isActive: i == realIndex,
              activeColor: activeColor,
            ),
          ),
        ),
      ],
    );
  }
}

/// Single Hero Banner Card with 100% Full Background Image & Crisp Text Overlay
class HeroBannerCard extends StatelessWidget {
  final HeroBannerModel model;

  const HeroBannerCard({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // LAYER 1: Full 100% Cover Background Image
            if (model.imageUrl != null && model.imageUrl!.trim().isNotEmpty)
              Image.network(
                model.imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (ctx, err, stack) => Image.asset(
                  model.imageAsset,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              )
            else
              Image.asset(
                model.imageAsset,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),

            // LAYER 2: Left-to-Right Dark Gradient Overlay for Text Readability
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.75),
                      Colors.black.withValues(alpha: 0.38),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.58, 1.0],
                  ),
                ),
              ),
            ),

            // LAYER 3: Banner Content (Badge + Title + Subtitle + CTA Button)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 11.0, 14.0, 11.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Block: Badge + 2-Line Heading + 2-Line Subtitle
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Badge Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              model.badgeIcon ?? Icons.work_rounded,
                              color: const Color(0xFFFFD700),
                              size: 10.5,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              model.badge,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Main Heading (2 Lines: Line 1 White Bold, Line 2 Yellow Highlight Bold)
                      RichText(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${model.titleLine1}\n',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15.5,
                                height: 1.12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.3,
                              ),
                            ),
                            TextSpan(
                              text: model.titleLine2,
                              style: const TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 15.5,
                                height: 1.12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 3),

                      // Subtitle (2 Lines)
                      Text(
                        model.subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 9.0,
                          height: 1.22,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),

                  // Bottom Block: White Capsule CTA Button
                  GestureDetector(
                    onTap: model.onTap ?? () {},
                    child: Container(
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            model.buttonText,
                            style: TextStyle(
                              color: model.buttonTextColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: model.arrowBgColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 9,
                            ),
                          ),
                        ],
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
}

/// Animated Indicator Widget
class AnimatedIndicator extends StatelessWidget {
  final bool isActive;
  final Color activeColor;

  const AnimatedIndicator({
    super.key,
    required this.isActive,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 22 : 8,
      decoration: BoxDecoration(
        color: isActive ? activeColor : activeColor.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
