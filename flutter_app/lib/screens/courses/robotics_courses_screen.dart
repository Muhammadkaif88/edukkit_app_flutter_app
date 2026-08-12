import 'package:flutter/material.dart';
import 'category_courses_screen.dart';

class RoboticsCoursesScreen extends StatelessWidget {
  const RoboticsCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryCoursesScreen(
      categoryTitle: 'Robotics',
      subtitle: 'Build, experiment & master robotics',
    );
  }
}
