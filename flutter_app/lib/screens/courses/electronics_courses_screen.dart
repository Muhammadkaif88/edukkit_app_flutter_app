import 'package:flutter/material.dart';
import 'category_courses_screen.dart';

class ElectronicsCoursesScreen extends StatelessWidget {
  const ElectronicsCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryCoursesScreen(
      categoryTitle: 'Electronics',
      subtitle: 'Master circuits, components & PCB design',
    );
  }
}
