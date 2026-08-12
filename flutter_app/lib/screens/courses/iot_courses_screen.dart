import 'package:flutter/material.dart';
import 'category_courses_screen.dart';

class IotCoursesScreen extends StatelessWidget {
  const IotCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryCoursesScreen(
      categoryTitle: 'IoT & Smart Technology',
      subtitle: 'Build smart IoT devices & cloud connections',
    );
  }
}
