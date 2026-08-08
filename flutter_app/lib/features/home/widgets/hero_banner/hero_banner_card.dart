import 'package:flutter/material.dart';
import '../../models/hero_banner_model.dart';
import 'banner_action_handler.dart';
import 'hero_banner_image.dart';
import 'hero_typography.dart';

/// Reusable Production Hero Banner Card Component.
/// Supports 100% optional fields with zero reserved empty space.
/// Image-Only banners render crisp background without dark gradient or empty placeholders.
class HeroBannerCard extends StatelessWidget {
  final HeroBannerModel banner;
  final VoidCallback? onTap;

  const HeroBannerCard({
    super.key,
    required this.banner,
    this.onTap,
  });

  void _handleBannerTap(BuildContext context) {
    if (onTap != null) {
      onTap!();
    } else {
      BannerActionHandler.execute(
        context,
        action: banner.clickAction,
        targetValue: banner.targetValue,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Admin Panel Safety Truncation for CTA Button (Max 18 chars)
    String? buttonText = banner.buttonText;
    if (buttonText != null && buttonText.length > 18) {
      buttonText = '${buttonText.substring(0, 15)}...';
    }

    final bool showGradientAndOverlay = banner.hasTextContent;

    return GestureDetector(
      onTap: () => _handleBannerTap(context),
      child: Container(
        height: 190,
        width: double.infinity,
        margin: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A), // Base color preventing edge gaps
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. FULL 100% CARD BACKGROUND IMAGE (Netflix / Play Store / Coursera Style)
              Positioned.fill(
                child: HeroBannerImage(
                  imagePath: banner.imagePath,
                  alignment: banner.imageAlignment ?? Alignment.center,
                  fit: BoxFit.cover,
                ),
              ),

              // 2. SMOOTH DARK GRADIENT OVERLAY (Rendered ONLY if banner has text/badge/button content)
              if (showGradientAndOverlay)
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xF50F172A), // 96% dark opacity on left for text legibility
                          Color(0xCC0F172A), // 80% opacity middle
                          Color(0x550F172A), // 33% opacity transition
                          Color(0x000F172A), // 0% opacity on right for clear artwork
                        ],
                        stops: [0.0, 0.40, 0.70, 1.0],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),

              // 3. TEXT & BUTTON OVERLAY (Zero reserved space - conditional rendering)
              if (showGradientAndOverlay)
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                    child: Row(
                      children: [
                        // Left Safe Content Column (58% width)
                        Expanded(
                          flex: 58,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Badge Pill (Rendered ONLY if present)
                              if (banner.hasBadge)
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    height: 20,
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF9500),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        banner.badge!.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9.0,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.4,
                                          height: 1.0,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                const SizedBox.shrink(),

                              // Title & Subtitle Column (Rendered ONLY if title or subtitle present)
                              if (banner.hasTitle || banner.hasSubtitle)
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (banner.hasTitle)
                                        Text(
                                          banner.title!,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: HeroTypography.title(context),
                                            fontWeight: FontWeight.w800,
                                            height: 1.1,
                                            letterSpacing: -0.3,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      if (banner.hasTitle && banner.hasSubtitle)
                                        const SizedBox(height: 6),
                                      if (banner.hasSubtitle)
                                        Text(
                                          banner.subtitle!,
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.88),
                                            fontSize: HeroTypography.subtitle(context),
                                            fontWeight: FontWeight.w400,
                                            height: 1.2,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                )
                              else
                                const SizedBox.shrink(),

                              // CTA Button (Rendered ONLY if buttonText present)
                              if (banner.hasButtonText)
                                Material(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  elevation: 2,
                                  shadowColor: const Color(0x33000000),
                                  child: InkWell(
                                    onTap: () => _handleBannerTap(context),
                                    borderRadius: BorderRadius.circular(18),
                                    child: Container(
                                      height: 36,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              buttonText!,
                                              style: const TextStyle(
                                                color: Color(0xFF0F172A),
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.w700,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(
                                            Icons.arrow_forward_rounded,
                                            color: Color(0xFF0F172A),
                                            size: 14.0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              else
                                const SizedBox.shrink(),
                            ],
                          ),
                        ),

                        // Right 42% Artwork Space
                        const Expanded(
                          flex: 42,
                          child: SizedBox.shrink(),
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
}
