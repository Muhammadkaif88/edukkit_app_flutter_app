import 'package:flutter/material.dart';

import '../../models/course_model.dart';
import '../../models/lesson_model.dart';
import 'course_playlist_screen.dart';
import 'data/courses_data.dart';

class LessonsListScreen extends StatelessWidget {
  final String courseTitle;
  final List<Map<String, dynamic>> lessons;
  final CourseModel? course;

  const LessonsListScreen({
    super.key,
    required this.courseTitle,
    required this.lessons,
    this.course,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveCourse = course ??
        CourseModel(
          id: 'course_playlist_id',
          title: courseTitle,
          description:
              'Start your robotics journey! Learn sensors, motors, controllers and build real-life robot projects.',
          shortDescription:
              'Start your robotics journey! Learn sensors, motors, controllers and build real-life robot projects.',
          instructor: 'Edukkit Team',
          price: 0,
          priceText: 'Included',
          thumbnailUrl: '',
          assetPath: 'assets/images/courses/featured_course_banner_artwork.png',
          category: 'Robotics',
          level: 'BEGINNER',
          rating: 4.8,
          lessonsCount: lessons.isNotEmpty ? lessons.length : 24,
          isKitIncluded: true,
        );

    final mappedLessons = lessons.isNotEmpty
        ? lessons.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final item = entry.value;
            return LessonModel(
              number: idx,
              title: item['title'] as String? ?? 'Lesson $idx',
              duration: item['duration'] as String? ?? '05:00',
              level: item['level'] as String? ?? 'Beginner',
              type: 'Video Lesson',
              isFreePreview: idx <= 3,
              isLocked: idx > 3,
              assetThumbnail: 'assets/images/courses/featured_course_banner_artwork.png',
            );
          }).toList()
        : CoursesData.getLessonsForCourse(effectiveCourse);

    return CoursePlaylistScreen(
      course: effectiveCourse,
      lessons: mappedLessons,
    );
  }
}
