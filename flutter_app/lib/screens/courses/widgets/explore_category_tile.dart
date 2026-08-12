import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/courses_data.dart';

class ExploreCategoryTile extends StatelessWidget {
  final CourseCategoryItem categoryItem;
  final VoidCallback onTap;

  const ExploreCategoryTile({
    super.key,
    required this.categoryItem,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: categoryItem.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: categoryItem.iconColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon in circle
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: categoryItem.iconColor.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    categoryItem.icon,
                    size: 24,
                    color: categoryItem.iconColor,
                  ),
                ),
                const SizedBox(height: 8),

                // Category Title
                Text(
                  categoryItem.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),

                // Course Count Subtitle
                Text(
                  categoryItem.courseCountText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
