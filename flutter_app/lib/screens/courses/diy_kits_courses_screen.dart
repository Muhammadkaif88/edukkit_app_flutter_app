import 'package:flutter/material.dart';
import 'category_courses_screen.dart';

class DiyKitsCoursesScreen extends StatelessWidget {
  const DiyKitsCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryCoursesScreen(
      categoryTitle: '3D Printing',
      subtitle: 'Create physical prototypes & 3D models',
    );
  }
}
