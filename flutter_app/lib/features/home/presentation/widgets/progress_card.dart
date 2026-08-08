import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/core.dart';
import '../../../../shared/shared.dart';

/// Data Architecture for Admin Panel management of the FREE DIY Videos Promo Card
class FreeDiyCardModel {
  final String badgeText;
  final String title;
  final String subtitleLine1;
  final String subtitleLine2;
  final String mascotImagePath;
  final List<String> features;
  final String ctaText;
  final String targetRoute;
  final bool isActive;

  const FreeDiyCardModel({
    this.badgeText = 'FREE DIY VIDEOS',
    this.title = 'Free DIY Kit Videos',
    this.subtitleLine1 = 'Watch step-by-step DIY projects',
    this.subtitleLine2 = 'videos for free.',
    this.mascotImagePath = 'assets/mascot/diy_banner_mascot.png',
    this.features = const ['HD Videos', 'Circuits', 'Code', 'Community'],
    this.ctaText = 'Watch Now →',
    this.targetRoute = '/diy-videos',
    this.isActive = true,
  });

  factory FreeDiyCardModel.fromJson(Map<String, dynamic> json) {
    return FreeDiyCardModel(
      badgeText: json['badgeText'] ?? 'FREE DIY VIDEOS',
      title: json['title'] ?? 'Free DIY Kit Videos',
      subtitleLine1: json['subtitleLine1'] ?? 'Watch step-by-step DIY projects',
      subtitleLine2: json['subtitleLine2'] ?? 'videos for free.',
      mascotImagePath: json['mascotImagePath'] ?? 'assets/images/free_diy_mascot.png',
      features: (json['features'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const ['HD Videos', 'Circuits', 'Code', 'Community'],
      ctaText: json['ctaText'] ?? 'Watch Now →',
      targetRoute: json['targetRoute'] ?? '/diy-videos',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'badgeText': badgeText,
      'title': title,
      'subtitleLine1': subtitleLine1,
      'subtitleLine2': subtitleLine2,
      'mascotImagePath': mascotImagePath,
      'features': features,
      'ctaText': ctaText,
      'targetRoute': targetRoute,
      'isActive': isActive,
    };
  }
}

/// ProgressCard Component (FREE DIY Videos Promo Card)
/// Features explicit 2-line subtitle (Line 1: Watch step-by-step DIY projects, Line 2: videos for free.),
/// 2x2 feature grid (HD Videos, Circuits, Code, Community), and lowered Watch Now CTA.
class ProgressCard extends StatelessWidget {
  final FreeDiyCardModel? model;
  final VoidCallback? onCtaTap;

  const ProgressCard({
    super.key,
    this.model,
    this.onCtaTap,
  });

  void _handleCtaTap(BuildContext context, String route) {
    if (onCtaTap != null) {
      onCtaTap!();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Navigating to Free DIY Videos...'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final promo = model ?? const FreeDiyCardModel();

    if (!promo.isActive) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenMarginHorizontal,
        vertical: AppSpacing.xs,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. MAIN COMPACT CARD CONTAINER
          AppCard(
            backgroundColor: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: Badge (▶ FREE DIY VIDEOS)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1976FF).withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.play_circle_fill_rounded,
                            color: Color(0xFF1976FF),
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            promo.badgeText,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.0,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1976FF),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Title & Explicit 2-Line Subtitle
                LayoutBuilder(
                  builder: (context, constraints) {
                    final textWidth = constraints.maxWidth * 0.64;
                    return SizedBox(
                      width: textWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            promo.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          // Line 1: Watch step-by-step DIY projects
                          Text(
                            promo.subtitleLine1,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          // Line 2: videos for free.
                          Text(
                            promo.subtitleLine2,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Bottom Row: 2x2 Feature Grid (HD Videos, Circuits, Code, Community) + Lowered Watch Now CTA
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Features Left (Using Flexible & Wrap with Community chip included)
                    Flexible(
                      child: Wrap(
                        spacing: 5.0,
                        runSpacing: 5.0,
                        children: [
                          _buildMicroFeature(Icons.hd_rounded, 'HD Videos'),
                          _buildMicroFeature(Icons.schema_rounded, 'Circuits'),
                          _buildMicroFeature(Icons.code_rounded, 'Code'),
                          _buildMicroFeature(Icons.groups_rounded, 'Community'),
                        ],
                      ),
                    ),

                    const SizedBox(width: 6),

                    // Primary CTA Button Right (Positioned lower down)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: InkWell(
                        onTap: () => _handleCtaTap(context, promo.targetRoute),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1976FF),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x331976FF),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            promo.ctaText,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. ENLARGED & LOWERED 3D POP-OUT MASCOT CUTOUT
          Positioned(
            top: -14,
            right: -28,
            child: GestureDetector(
              onTap: () => _handleCtaTap(context, promo.targetRoute),
              child: SizedBox(
                width: 180,
                height: 180,
                child: Image.asset(
                  'assets/images/free_diy_mascot.png',
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, stack) => Image.asset(
                    'assets/mascot/diy_banner_mascot.png',
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) => Image.asset(
                      'assets/mascot/free_diy_mascot.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMicroFeature(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11,
            color: const Color(0xFF1976FF),
          ),
          const SizedBox(width: 3.5),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.0,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}
