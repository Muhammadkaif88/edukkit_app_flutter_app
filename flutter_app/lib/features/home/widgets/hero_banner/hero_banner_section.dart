import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/hero_banner_model.dart';
import 'hero_banner_card.dart';
import 'hero_banner_indicator.dart';

/// Reusable Production Foundation for Edukkit Hero Banner Carousel Section.
/// Features true infinite one-direction auto-scroll, swipe pause/resume, and zero-flicker indicators.
class HeroBannerSection extends StatefulWidget {
  final List<HeroBannerModel>? banners;
  final double height;
  final bool enableAutoScroll;
  final Duration autoScrollDuration;
  final Function(HeroBannerModel banner)? onBannerTap;
  final bool showIndicator;

  const HeroBannerSection({
    super.key,
    this.banners,
    this.height = 190.0,
    this.enableAutoScroll = true,
    this.autoScrollDuration = const Duration(seconds: 5),
    this.onBannerTap,
    this.showIndicator = false,
  });

  @override
  State<HeroBannerSection> createState() => _HeroBannerSectionState();
}

class _HeroBannerSectionState extends State<HeroBannerSection> {
  late final PageController _pageController;
  Timer? _autoScrollTimer;
  Timer? _userSwipeResumeTimer;
  int _currentPage = 0;
  bool _isUserSwiping = false;

  List<HeroBannerModel> get _activeBanners {
    final list = widget.banners ?? HeroBannerModel.defaultBanners;
    final active = list.where((b) => b.isScheduledActive).toList();
    active.sort((a, b) {
      final int priorityComp = b.priority.compareTo(a.priority);
      if (priorityComp != 0) return priorityComp;
      return a.displayOrder.compareTo(b.displayOrder);
    });
    return active.isEmpty ? HeroBannerModel.defaultBanners : active;
  }

  @override
  void initState() {
    super.initState();
    final banners = _activeBanners;
    // Set initial page to a large multiple of banner length for true infinite scroll
    final int initialPage = banners.length > 1 ? 1000 * banners.length : 0;
    _currentPage = initialPage;
    _pageController = PageController(initialPage: initialPage);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    if (!widget.enableAutoScroll) return;
    _autoScrollTimer?.cancel();

    final banners = _activeBanners;
    if (banners.length <= 1) return;

    final Duration duration = Duration(
      seconds: banners[_currentPage % banners.length].autoSlideDurationSeconds,
    );

    _autoScrollTimer = Timer.periodic(duration, (timer) {
      if (!mounted || _activeBanners.length <= 1 || _isUserSwiping) return;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _onUserStartSwipe() {
    _isUserSwiping = true;
    _autoScrollTimer?.cancel();
    _userSwipeResumeTimer?.cancel();
  }

  void _onUserEndSwipe() {
    if (!_isUserSwiping) return;
    _isUserSwiping = false;
    _userSwipeResumeTimer?.cancel();
    // Resume auto-slide after 5 seconds of inactivity
    _userSwipeResumeTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        _startAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _userSwipeResumeTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banners = _activeBanners;
    final int realIndex = _currentPage % banners.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Infinite One-Direction PageView Container
        SizedBox(
          height: widget.height,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (notification is ScrollStartNotification) {
                if (notification.dragDetails != null) {
                  _onUserStartSwipe();
                }
              } else if (notification is ScrollEndNotification) {
                _onUserEndSwipe();
              }
              return false;
            },
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final banner = banners[index % banners.length];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: HeroBannerCard(
                    banner: banner,
                    onTap: () => widget.onBannerTap?.call(banner),
                  ),
                );
              },
            ),
          ),
        ),

        if (widget.showIndicator) ...[
          const SizedBox(height: 10),
          // 2. Banner Page Indicators (Always aligned forward)
          HeroBannerIndicator(
            itemCount: banners.length,
            currentIndex: realIndex,
            activeColor: const Color(0xFF1976FF),
            inactiveColor: const Color(0xFFCBD5E1),
            onDotTap: (targetIndex) {
              final int currentRealIndex = _currentPage % banners.length;
              int diff = targetIndex - currentRealIndex;
              if (diff < 0) diff += banners.length;
              final int targetPage = _currentPage + diff;
              _pageController.animateToPage(
                targetPage,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
              );
            },
          ),
        ],
      ],
    );
  }
}
