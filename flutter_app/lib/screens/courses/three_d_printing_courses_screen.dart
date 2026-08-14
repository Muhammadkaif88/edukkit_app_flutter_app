import 'package:flutter/material.dart';
import 'category_courses_screen.dart';

/// Dedicated 3D Printing Category Courses Screen for Edukkit.
/// Displays 3D Printing courses (e.g. 3D Printing for Beginners, 3D Modeling with Fusion 360)
/// reusing the exact Edukkit category page architecture.
class ThreeDPrintingCoursesScreen extends StatelessWidget {
  const ThreeDPrintingCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryCoursesScreen(
      categoryTitle: '3D Printing',
      subtitle: 'Learn 3D printing, modeling and design',
    );
  }
}
