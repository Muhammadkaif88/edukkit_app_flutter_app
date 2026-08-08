import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../../../shared/shared.dart';

class CategoryItemModel {
  final String id;
  final String title;
  final IconData icon;
  final Color color;

  const CategoryItemModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
  });
}

/// CategorySection Component for Edukkit Home Screen
/// Renders EdTech categories (Robotics, AI, IoT, Electronics, DIY Kits, Hardware Store, etc.)
class CategorySection extends StatelessWidget {
  final List<CategoryItemModel>? categories;
  final void Function(CategoryItemModel category)? onCategoryTap;

  const CategorySection({
    super.key,
    this.categories,
    this.onCategoryTap,
  });

  static const List<CategoryItemModel> defaultCategories = [
    CategoryItemModel(
      id: 'robotics',
      title: 'Robotics',
      icon: Icons.smart_toy_rounded,
      color: AppColors.robotics,
    ),
    CategoryItemModel(
      id: 'ai',
      title: 'AI & ML',
      icon: Icons.psychology_rounded,
      color: AppColors.ai,
    ),
    CategoryItemModel(
      id: 'iot',
      title: 'IoT & Smart',
      icon: Icons.wifi_rounded,
      color: AppColors.iot,
    ),
    CategoryItemModel(
      id: 'electronics',
      title: 'Electronics',
      icon: Icons.memory_rounded,
      color: AppColors.electronics,
    ),
    CategoryItemModel(
      id: 'diy_kits',
      title: 'DIY Kits',
      icon: Icons.build_circle_rounded,
      color: AppColors.diyKits,
    ),
    CategoryItemModel(
      id: 'store',
      title: 'Hardware Store',
      icon: Icons.shopping_bag_rounded,
      color: AppColors.store,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final list = categories ?? defaultCategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          title: 'Explore Domains 🚀',
          subtitle: 'Choose your learning path',
        ),
        AppSpacing.vGapSm,
        SizedBox(
          height: 100,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMarginHorizontal),
            scrollDirection: Axis.horizontal,
            itemCount: list.length,
            separatorBuilder: (context, index) => AppSpacing.hGapSm,
            itemBuilder: (context, index) {
              final category = list[index];
              return GestureDetector(
                onTap: () => onCategoryTap?.call(category),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: category.color.withValues(alpha: 0.12),
                        borderRadius: AppRadius.borderXxl,
                        border: Border.all(
                          color: category.color.withValues(alpha: 0.25),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          category.icon,
                          color: category.color,
                          size: 28,
                        ),
                      ),
                    ),
                    AppSpacing.vGapXs,
                    Text(
                      category.title,
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
