import 'package:flutter/material.dart';
import '../../../widgets/edukkit_category_card.dart';
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
    return EdukkitCategoryCard(
      categoryName: categoryItem.title,
      courseCountText: categoryItem.courseCountText,
      iconAsset: categoryItem.iconAsset,
      backgroundColor: categoryItem.backgroundColor,
      accentColor: categoryItem.iconColor,
      onTap: onTap,
    );
  }
}
