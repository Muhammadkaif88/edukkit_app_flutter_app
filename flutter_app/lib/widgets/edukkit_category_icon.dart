import 'package:flutter/material.dart';

/// Reusable Edukkit 3D Category Icon Component.
/// Renders a custom 3D educational category illustration inside a clean white circular container
/// with soft elevation shadow.
class EdukkitCategoryIcon extends StatelessWidget {
  final String iconAsset;
  final double size;
  final double iconRatio;
  final Color? shadowColor;

  const EdukkitCategoryIcon({
    super.key,
    required this.iconAsset,
    this.size = 58.0,
    this.iconRatio = 0.88,
    this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    final double iconDimension = size * iconRatio;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: shadowColor ?? const Color(0x120F172A),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: iconDimension,
          height: iconDimension,
          child: Image.asset(
            iconAsset,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.category_rounded,
              size: iconDimension * 0.7,
              color: const Color(0xFF4F46E5),
            ),
          ),
        ),
      ),
    );
  }
}
