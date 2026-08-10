import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Data Model for Admin-Controlled Community Banner Architecture
class JoinCommunityModel {
  final bool communityBannerEnabled;
  final String communityBannerImage;
  final String communityBannerTitle;
  final String communityBannerSubtitle;
  final String communityBannerButtonText;
  final String communityBannerAction;

  const JoinCommunityModel({
    this.communityBannerEnabled = true,
    this.communityBannerImage = 'assets/banners/community_banner_artwork.png',
    this.communityBannerTitle = 'JOIN OUR COMMUNITY!',
    this.communityBannerSubtitle = 'Learn • Share • Build • Grow Together',
    this.communityBannerButtonText = 'Join Now',
    this.communityBannerAction = '/community',
  });

  factory JoinCommunityModel.fromJson(Map<String, dynamic> json) {
    return JoinCommunityModel(
      communityBannerEnabled: json['communityBannerEnabled'] ?? true,
      communityBannerImage: json['communityBannerImage'] ?? '',
      communityBannerTitle: json['communityBannerTitle'] ?? 'JOIN OUR COMMUNITY!',
      communityBannerSubtitle: json['communityBannerSubtitle'] ?? 'Learn • Share • Build • Grow Together',
      communityBannerButtonText: json['communityBannerButtonText'] ?? 'Join Now',
      communityBannerAction: json['communityBannerAction'] ?? '/community',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'communityBannerEnabled': communityBannerEnabled,
      'communityBannerImage': communityBannerImage,
      'communityBannerTitle': communityBannerTitle,
      'communityBannerSubtitle': communityBannerSubtitle,
      'communityBannerButtonText': communityBannerButtonText,
      'communityBannerAction': communityBannerAction,
    };
  }
}

/// Modular 3-Layer "Join Our Community" Promotional Banner Widget
/// ---------------------------------------------------------------
/// LAYER 1: Dynamic Background Image (Admin controllable via BoxFit.cover)
/// LAYER 2: Text / Badge / CTA Overlay (Center/Right aligned, responsive space reserved)
/// LAYER 3: Mascot Overlay (Popping out left, dynamically scaled & contained within screen bounds)
class JoinCommunityBanner extends StatelessWidget {
  final JoinCommunityModel? model;
  final VoidCallback? onTap;

  const JoinCommunityBanner({
    super.key,
    this.model,
    this.onTap,
  });

  void _handleTap(BuildContext context, JoinCommunityModel config) {
    if (onTap != null) {
      onTap!();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Opening Edukkit Community (${config.communityBannerAction})...',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF4F46E5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = model ?? const JoinCommunityModel();

    if (!config.communityBannerEnabled) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Horizontal padding reserved for screen margins
        const double horizontalMargin = 16.0;
        final double maxAvailableWidth = math.max(0.0, constraints.maxWidth - (horizontalMargin * 2));

        // Design Reference Specifications
        const double refBannerWidth = 310.0;
        const double refBannerHeight = 124.0;
        const double refMascotOverflow = 65.0; // Left popping-out width
        const double refTotalWidth = refBannerWidth + refMascotOverflow; // 394.0

        // Scale factor calculation to guarantee zero screen overflow
        final double scale = (maxAvailableWidth / refTotalWidth).clamp(0.65, 1.0);

        final double bannerWidth = refBannerWidth * scale;
        final double bannerHeight = refBannerHeight * scale;
        final double mascotOverflow = refMascotOverflow * scale;
        final double mascotWidth = 137.0 * scale;
        final double mascotHeight = 147.0 * scale;
        final double buttonRight = 204.0 * scale;
        final double buttonBottom = 5.5 * scale;
        final double buttonFontSize = (9.0 * scale).clamp(7.5, 10.0);
        final double buttonIconSize = (10.0 * scale).clamp(8.0, 11.0);

        final double totalEnsembleWidth = mascotOverflow + bannerWidth;
        final double stackHeight = math.max(bannerHeight, mascotHeight);

        return Padding(
          padding: const EdgeInsets.only(
            left: horizontalMargin,
            right: horizontalMargin,
            top: 0,
            bottom: 2.0,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: totalEnsembleWidth,
              height: stackHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // MAIN BANNER CONTAINER
                  Positioned(
                    left: mascotOverflow,
                    bottom: 0,
                    child: Container(
                      width: bannerWidth,
                      height: bannerHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16 * scale),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0x1A4F46E5),
                            blurRadius: 10 * scale,
                            offset: Offset(0, 3 * scale),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16 * scale),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _handleTap(context, config),
                            borderRadius: BorderRadius.circular(16 * scale),
                            child: Stack(
                              children: [
                                // LAYER 1: DYNAMIC BACKGROUND IMAGE (OR BRAND GRADIENT FALLBACK)
                                Positioned.fill(
                                  child: _buildBackgroundImage(config.communityBannerImage),
                                ),

                                // LAYER 2: SLEEK COMPACT CTA BUTTON OVERLAY
                                Positioned(
                                  bottom: buttonBottom,
                                  right: buttonRight,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10 * scale,
                                      vertical: 3.5 * scale,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF4F46E5),
                                          Color(0xFF6366F1),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12 * scale),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0x334F46E5),
                                          blurRadius: 5 * scale,
                                          offset: Offset(0, 1.5 * scale),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          config.communityBannerButtonText,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: buttonFontSize,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 3 * scale),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: buttonIconSize,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // LAYER 3: MASCOT OVERLAY (BOUNDED WITHIN STACK BOUNDARIES)
                  Positioned(
                    left: -12,
                    bottom: 0,
                    child: IgnorePointer(
                      child: SizedBox(
                        width: mascotWidth,
                        height: mascotHeight,
                        child: Image.asset(
                          'assets/mascot/community_mascot_leaning.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Image.asset(
                            'assets/images/community_mascot_leaning.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackgroundImage(String imagePath) {
    final trimmed = imagePath.trim();

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: trimmed,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildDefaultGradientBackground(),
        errorWidget: (context, url, error) => _buildDefaultGradientBackground(),
      );
    }

    if (trimmed.isNotEmpty) {
      return Image.asset(
        trimmed,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        errorBuilder: (context, error, stackTrace) => _buildDefaultGradientBackground(),
      );
    }

    return _buildDefaultGradientBackground();
  }

  Widget _buildDefaultGradientBackground() {
    return Image.asset(
      'assets/banners/community_banner_artwork.png',
      fit: BoxFit.cover,
      alignment: Alignment.center,
      errorBuilder: (context, error, stackTrace) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFEDE9FE), // Light lavender top-left
              Color(0xFFE0E7FF), // Soft indigo bottom-right
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}

