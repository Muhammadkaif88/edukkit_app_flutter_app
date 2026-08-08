import 'package:flutter/material.dart';

/// Production-Grade Reusable Canva-Frame Image Widget for Edukkit Banners.
/// Universal image fitting solution for Hero Banner, Store Banner, Offer Banner, and Course Banner.
/// Features:
/// - Automatic Asset & Network URL detection
/// - Canva-style frame cropping (BoxFit.cover preserving aspect ratio with zero white space)
/// - Customizable Alignment, BoxFit & BorderRadius
/// - Dark fallback gradient on load error or network fetch
class HeroBannerImage extends StatelessWidget {
  final String imagePath;
  final AlignmentGeometry alignment;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const HeroBannerImage({
    super.key,
    required this.imagePath,
    this.alignment = Alignment.centerRight,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = _buildImageSource(context);

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: SizedBox.expand(child: imageWidget),
      );
    }

    return SizedBox.expand(child: imageWidget);
  }

  Widget _buildImageSource(BuildContext context) {
    final bool isNetwork = imagePath.startsWith('http://') || imagePath.startsWith('https://');

    if (isNetwork) {
      return Image.network(
        imagePath,
        fit: fit,
        alignment: alignment,
        filterQuality: FilterQuality.high,
        errorBuilder: (ctx, err, stack) => _buildFallbackBackground(),
        loadingBuilder: (ctx, child, progress) {
          if (progress == null) return child;
          return _buildFallbackBackground();
        },
      );
    }

    return Image.asset(
      imagePath,
      fit: fit,
      alignment: alignment,
      filterQuality: FilterQuality.high,
      errorBuilder: (ctx, err, stack) => _buildFallbackBackground(),
    );
  }

  Widget _buildFallbackBackground() {
    return Image.asset(
      'assets/images/home/banner_bg_diy_kits.png',
      fit: fit,
      alignment: alignment,
      filterQuality: FilterQuality.high,
      errorBuilder: (ctx, err, stack) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
    );
  }
}
