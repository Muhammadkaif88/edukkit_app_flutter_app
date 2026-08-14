import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../../../shared/shared.dart';
import '../../../../widgets/edukkit_category_icon.dart';
import '../../../../screens/courses/robotics_courses_screen.dart';
import '../../../../screens/courses/iot_courses_screen.dart';
import '../../../../screens/courses/electronics_courses_screen.dart';
import '../../../../screens/courses/three_d_printing_courses_screen.dart';
import '../../../../screens/store/diy_kits_screen.dart';

class CategoryItemModel {
  final String id;
  final String title;
  final String? imageAsset;
  final IconData? icon;
  final Color color;

  const CategoryItemModel({
    required this.id,
    required this.title,
    this.imageAsset,
    this.icon,
    required this.color,
  });
}

/// CategorySection Component for Edukkit Home Screen
/// Renders 5 static, responsive EdTech categories across all mobile screen sizes
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
      imageAsset: 'assets/icons/category_robotics.png',
      icon: Icons.smart_toy_rounded,
      color: AppColors.robotics,
    ),
    CategoryItemModel(
      id: 'iot',
      title: 'IoT & Smart',
      imageAsset: 'assets/icons/category_iot.png',
      icon: Icons.wifi_rounded,
      color: AppColors.iot,
    ),
    CategoryItemModel(
      id: 'electronics',
      title: 'Electronics',
      imageAsset: 'assets/icons/category_electronics.png',
      icon: Icons.memory_rounded,
      color: AppColors.electronics,
    ),
    CategoryItemModel(
      id: 'diy_kits',
      title: 'DIY Kits',
      imageAsset: 'assets/icons/category_diy_kits.png',
      icon: Icons.build_circle_rounded,
      color: AppColors.diyKits,
    ),
    CategoryItemModel(
      id: '3d_printing',
      title: '3D Printing',
      imageAsset: 'assets/icons/category_3d_printing.png',
      icon: Icons.view_in_ar_rounded,
      color: AppColors.store,
    ),
  ];

  void _defaultHandleTap(BuildContext context, CategoryItemModel category) {
    if (onCategoryTap != null) {
      onCategoryTap!(category);
      return;
    }

    Widget? targetScreen;
    switch (category.id) {
      case 'robotics':
        targetScreen = const RoboticsCoursesScreen();
        break;
      case 'iot':
        targetScreen = const IotCoursesScreen();
        break;
      case 'electronics':
        targetScreen = const ElectronicsCoursesScreen();
        break;
      case 'diy_kits':
      case 'diy-kits':
        targetScreen = const DiyKitsScreen();
        break;
      case '3d_printing':
      case '3d-printing':
        targetScreen = const ThreeDPrintingCoursesScreen();
        break;
      default:
        targetScreen = null;
        break;
    }

    if (targetScreen != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => targetScreen!),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${category.title} courses coming soon!'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: list.map((category) {
              return Expanded(
                child: GestureDetector(
                  onTap: () => _defaultHandleTap(context, category),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // Dynamic icon size scaling responsively for all phone screen sizes
                          final double iconSize = (constraints.maxWidth * 0.85).clamp(46.0, 56.0);

                          return category.imageAsset != null && category.imageAsset!.isNotEmpty
                              ? EdukkitCategoryIcon(
                                  iconAsset: category.imageAsset!,
                                  size: iconSize,
                                  iconRatio: 0.88,
                                  shadowColor: category.color.withValues(alpha: 0.15),
                                )
                              : Container(
                                  width: iconSize,
                                  height: iconSize,
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
                                      category.icon ?? Icons.category_rounded,
                                      color: category.color,
                                      size: iconSize * 0.5,
                                    ),
                                  ),
                                );
                        },
                      ),
                      AppSpacing.vGapXs,
                      Text(
                        category.title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
