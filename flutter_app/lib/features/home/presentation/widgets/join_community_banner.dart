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
/// LAYER 2: Text / Badge / CTA Overlay (Center/Right aligned, 90px left space reserved)
/// LAYER 3: Mascot Overlay Placeholder (Stack clipBehavior: Clip.none for mascot overlay)
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

    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0, top: 20.0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // MAIN BANNER CONTAINER (329px x 106px)
            Container(
              width: 329,
              height: 106,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A4F46E5),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _handleTap(context, config),
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        // LAYER 1: DYNAMIC BACKGROUND IMAGE (OR BRAND GRADIENT FALLBACK)
                        Positioned.fill(
                          child: _buildBackgroundImage(config.communityBannerImage),
                        ),

                        // LAYER 2: SLEEK COMPACT CTA BUTTON OVERLAY
                        Positioned(
                          bottom: 5.5,
                          right: 207,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF4F46E5),
                                  Color(0xFF6366F1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x334F46E5),
                                  blurRadius: 5,
                                  offset: Offset(0, 1.5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  config.communityBannerButtonText,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9.0,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 10,
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

            // LAYER 3: MASCOT OVERLAY (POPPING OUT OF THE LEFT EDGE OF THE BANNER)
            Positioned(
              left: -70,
              bottom: 0,
              child: IgnorePointer(
                child: SizedBox(
                  width: 125,
                  height: 135,
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
