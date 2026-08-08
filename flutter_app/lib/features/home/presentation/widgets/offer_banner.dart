import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/core.dart';

/// Firebase & Admin Ready Data Architecture for Community / Promotional Banners
/// Architecture designed identically to Hero Banner for universal engine reuse.
class CommunityBannerModel {
  final String id;
  final String badge;
  final String title;
  final String subtitle;
  final String buttonText;
  final String illustrationImage;
  final String illustrationType;
  final bool isMascotEnabled;
  final String backgroundType;
  final Color backgroundColor;
  final List<Color> gradientColors;
  final Color buttonColor;
  final Color buttonTextColor;
  final String clickAction;
  final String route;
  final String url;
  final String joinedCountText;
  final bool isActive;
  final int displayOrder;

  const CommunityBannerModel({
    required this.id,
    this.badge = 'JOIN OUR COMMUNITY',
    this.title = 'Learn, Share & Grow with Makers! 👋',
    this.subtitle = 'Be part of our amazing maker community. Connect, collaborate, learn and build together.',
    this.buttonText = 'Join Community',
    this.illustrationImage = 'assets/images/free_diy_mascot.png',
    this.illustrationType = 'mascot_group',
    this.isMascotEnabled = true,
    this.backgroundType = 'gradient',
    this.backgroundColor = const Color(0xFFF4F0FF),
    this.gradientColors = const [Color(0xFFF8F5FF), Color(0xFFEDE9FE)],
    this.buttonColor = const Color(0xFF6366F1),
    this.buttonTextColor = Colors.white,
    this.clickAction = 'route',
    this.route = '/community',
    this.url = '',
    this.joinedCountText = '12.8K+ Makers Joined',
    this.isActive = true,
    this.displayOrder = 1,
  });

  factory CommunityBannerModel.fromJson(Map<String, dynamic> json) {
    List<Color> parseGradient(dynamic val) {
      if (val is List) {
        return val.map((e) {
          final hex = e.toString().replaceAll('#', '');
          return Color(int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16));
        }).toList();
      }
      return const [Color(0xFFF8F5FF), Color(0xFFEDE9FE)];
    }

    Color parseColor(dynamic val, Color fallback) {
      if (val == null) return fallback;
      final hex = val.toString().replaceAll('#', '');
      return Color(int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16));
    }

    return CommunityBannerModel(
      id: json['id'] ?? '',
      badge: json['badge'] ?? 'JOIN OUR COMMUNITY',
      title: json['title'] ?? 'Learn, Share & Grow with Makers! 👋',
      subtitle: json['subtitle'] ?? 'Be part of our amazing maker community. Connect, collaborate, learn and build together.',
      buttonText: json['buttonText'] ?? 'Join Community',
      illustrationImage: json['illustrationImage'] ?? 'assets/images/free_diy_mascot.png',
      illustrationType: json['illustrationType'] ?? 'mascot_group',
      isMascotEnabled: json['isMascotEnabled'] ?? true,
      backgroundType: json['backgroundType'] ?? 'gradient',
      backgroundColor: parseColor(json['backgroundColor'], const Color(0xFFF4F0FF)),
      gradientColors: parseGradient(json['gradientColors']),
      buttonColor: parseColor(json['buttonColor'], const Color(0xFF6366F1)),
      buttonTextColor: parseColor(json['buttonTextColor'], Colors.white),
      clickAction: json['clickAction'] ?? 'route',
      route: json['route'] ?? '/community',
      url: json['url'] ?? '',
      joinedCountText: json['joinedCountText'] ?? '12.8K+ Makers Joined',
      isActive: json['isActive'] ?? true,
      displayOrder: json['displayOrder'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'badge': badge,
      'title': title,
      'subtitle': subtitle,
      'buttonText': buttonText,
      'illustrationImage': illustrationImage,
      'illustrationType': illustrationType,
      'isMascotEnabled': isMascotEnabled,
      'backgroundType': backgroundType,
      'backgroundColor': '#${backgroundColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
      'gradientColors': gradientColors.map((c) => '#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}').toList(),
      'buttonColor': '#${buttonColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
      'buttonTextColor': '#${buttonTextColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
      'clickAction': clickAction,
      'route': route,
      'url': url,
      'joinedCountText': joinedCountText,
      'isActive': isActive,
      'displayOrder': displayOrder,
    };
  }
}

typedef OfferBannerModel = CommunityBannerModel;

/// Reusable Community Promotional Banner Component (OfferBanner)
/// Features official 3D Edukkit Mascot family illustration with subtle float animation,
/// 24dp rounded corners, light purple gradient background, and dynamic Admin control.
class OfferBanner extends StatefulWidget {
  final CommunityBannerModel? model;
  final VoidCallback? onTap;

  const OfferBanner({
    super.key,
    this.model,
    this.onTap,
  });

  @override
  State<OfferBanner> createState() => _OfferBannerState();
}

class _OfferBannerState extends State<OfferBanner> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleBannerTap(BuildContext context, CommunityBannerModel banner) {
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening ${banner.title} (${banner.route})...'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final banner = widget.model ?? const CommunityBannerModel(id: 'default_community_banner');

    if (!banner.isActive) {
      return const SizedBox.shrink();
    }

    final backgroundDecoration = banner.backgroundType == 'solid'
        ? BoxDecoration(
            color: banner.backgroundColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE9D5FF), width: 1.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F7C3AED),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          )
        : BoxDecoration(
            gradient: LinearGradient(
              colors: banner.gradientColors.length >= 2
                  ? banner.gradientColors
                  : [const Color(0xFFF8F5FF), const Color(0xFFEDE9FE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE9D5FF), width: 1.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F7C3AED),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenMarginHorizontal,
        vertical: AppSpacing.xs,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. MAIN BANNER CARD
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _handleBannerTap(context, banner),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: double.infinity,
                decoration: backgroundDecoration,
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    // Extremely subtle background sparkles & tech icons
                    Positioned(
                      top: 16,
                      right: 140,
                      child: Opacity(
                        opacity: 0.12,
                        child: Icon(Icons.smart_toy_outlined, size: 28, color: Color(0xFF6D28D9)),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 180,
                      child: Opacity(
                        opacity: 0.12,
                        child: Icon(Icons.code_rounded, size: 26, color: Color(0xFF6D28D9)),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      right: 60,
                      child: Opacity(
                        opacity: 0.10,
                        child: Icon(Icons.laptop_chromebook_rounded, size: 24, color: Color(0xFF6D28D9)),
                      ),
                    ),

                    // Left Content Area
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 360;
                          final leftWidth = isNarrow ? constraints.maxWidth * 0.58 : constraints.maxWidth * 0.62;

                          return SizedBox(
                            width: leftWidth,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Small Badge: 💜 JOIN OUR COMMUNITY
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEDE9FE),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.groups_rounded,
                                        size: 13,
                                        color: Color(0xFF6D28D9),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        banner.badge.toUpperCase(),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10.0,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF6D28D9),
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // Headline
                                Text(
                                  banner.title,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 17.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1E1B4B),
                                    height: 1.2,
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                const SizedBox(height: 6),

                                // Subtitle
                                Text(
                                  banner.subtitle,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF475569),
                                    height: 1.25,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                const SizedBox(height: 14),

                                // CTA Button
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.5),
                                  decoration: BoxDecoration(
                                    color: banner.buttonColor,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: banner.buttonColor.withValues(alpha: 0.35),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        banner.buttonText,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w800,
                                          color: banner.buttonTextColor,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 14,
                                        color: banner.buttonTextColor,
                                      ),
                                    ],
                                  ),
                                ),

                                // Joined Count Social Proof Pill
                                if (banner.joinedCountText.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.80),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('👥', style: TextStyle(fontSize: 11)),
                                        const SizedBox(width: 4),
                                        Text(
                                          banner.joinedCountText,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF334155),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          width: 5,
                                          height: 5,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF22C55E),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Active',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. RIGHT SIDE 3D EDUKKIT MASCOT FAMILY ILLUSTRATION (WITH SLIGHT POP-OUT)
          if (banner.isMascotEnabled)
            Positioned(
              top: -18,
              right: 2,
              bottom: -4,
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    final floatY = math.sin(_animController.value * 2 * math.pi * 3) * 2.0;

                    return Transform.translate(
                      offset: Offset(0, floatY),
                      child: SizedBox(
                        width: 160,
                        child: _buildOfficialMascotGroup(banner.illustrationImage),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOfficialMascotGroup(String rawPath) {
    final trimmed = rawPath.trim();

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: trimmed,
        height: 180,
        fit: BoxFit.contain,
        placeholder: (ctx, url) => const SizedBox.shrink(),
        errorWidget: (ctx, url, err) => _build3DMascotFamilyArtwork(),
      );
    }

    final resolved = trimmed.startsWith('assets/')
        ? trimmed
        : 'assets/mascot/$trimmed${trimmed.contains('.') ? '' : '.png'}';

    return Image.asset(
      resolved,
      height: 180,
      fit: BoxFit.contain,
      errorBuilder: (ctx, err, stack) => Image.asset(
        'assets/images/free_diy_mascot.png',
        height: 180,
        fit: BoxFit.contain,
        errorBuilder: (c, e, s) => _build3DMascotFamilyArtwork(),
      ),
    );
  }

  Widget _build3DMascotFamilyArtwork() {
    return Stack(
      alignment: Alignment.bottomRight,
      clipBehavior: Clip.none,
      children: [
        // Main Edukkit Mascot Character (Blue Body, Yellow Arms, White Gloves, Waving)
        Container(
          width: 96,
          height: 145,
          decoration: BoxDecoration(
            color: const Color(0xFF1976FF),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x25000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned(
                top: 20,
                child: Text(
                  'e',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFBBF24),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Transform.rotate(
                  angle: 0.3,
                  child: const Icon(
                    Icons.waving_hand_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Small Mascot 2 (Thumbs Up / Laptop)
        Positioned(
          right: 70,
          bottom: 0,
          child: Container(
            width: 54,
            height: 88,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x20000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.thumb_up_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
