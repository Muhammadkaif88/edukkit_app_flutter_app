import 'package:flutter/material.dart';
import '../../../models/course_model.dart';

class CourseCategoryItem {
  final String id;
  final String title;
  final String courseCountText;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const CourseCategoryItem({
    required this.id,
    required this.title,
    required this.courseCountText,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });
}

class CoursesData {
  static const List<String> filterCategories = [
    'All',
    'Robotics',
    'Electronics',
    'AI',
    '3D Printing',
    'IoT & Smart Technology',
  ];

  static const List<CourseCategoryItem> exploreCategories = [
    CourseCategoryItem(
      id: 'robotics',
      title: 'Robotics',
      courseCountText: '3 Courses',
      icon: Icons.smart_toy_rounded,
      iconColor: Color(0xFF7C3AED),
      backgroundColor: Color(0xFFF3E8FF),
    ),
    CourseCategoryItem(
      id: 'electronics',
      title: 'Electronics',
      courseCountText: '3 Courses',
      icon: Icons.developer_board_rounded,
      iconColor: Color(0xFFEA580C),
      backgroundColor: Color(0xFFFFEDD5),
    ),
    CourseCategoryItem(
      id: 'ai',
      title: 'AI',
      courseCountText: '2 Courses',
      icon: Icons.auto_awesome_rounded,
      iconColor: Color(0xFF0284C7),
      backgroundColor: Color(0xFFE0F2FE),
    ),
    CourseCategoryItem(
      id: '3d_printing',
      title: '3D Printing',
      courseCountText: '2 Courses',
      icon: Icons.view_in_ar_rounded,
      iconColor: Color(0xFFDB2777),
      backgroundColor: Color(0xFFFCE7F3),
    ),
    CourseCategoryItem(
      id: 'iot',
      title: 'IoT & Smart Technology',
      courseCountText: '2 Courses',
      icon: Icons.sensors_rounded,
      iconColor: Color(0xFF0D9488),
      backgroundColor: Color(0xFFCCFBF1),
    ),
  ];

  static final CourseModel featuredCourse = CourseModel(
    id: 'feat_robotics_01',
    title: 'Junior Robotics Engineer',
    description:
        'Start your robotics journey! Learn sensors, motors, controllers and build real-life robot projects.',
    shortDescription:
        'Start your robotics journey! Learn sensors, motors, controllers and build real-life robot projects.',
    instructor: 'Edukkit Robotics Lab',
    price: 0,
    priceText: 'Included',
    thumbnailUrl: '',
    assetPath: 'assets/images/home/course_robotics_student.png',
    category: 'Robotics',
    level: 'BEGINNER',
    rating: 4.8,
    lessonsCount: 24,
    isKitIncluded: true,
    isPopular: true,
    badgeText: 'POPULAR',
    badgeColorHex: 0xFFEA580C,
  );

  static final List<CourseModel> popularCourses = [
    CourseModel(
      id: 'pop_electronics_01',
      title: 'Electronics Fundamentals',
      description:
          'Understand electronic components, circuits & measurements.',
      shortDescription:
          'Understand electronic components, circuits & measurements.',
      instructor: 'Edukkit Circuits Team',
      price: 799,
      priceText: '₹799',
      thumbnailUrl: '',
      assetPath: 'assets/images/courses/electronics_board_3d.png',
      category: 'Electronics',
      level: 'BEGINNER',
      rating: 4.7,
      lessonsCount: 18,
      isKitIncluded: true,
      badgeText: 'KIT INCLUDED',
      badgeColorHex: 0xFF10B981,
    ),
    CourseModel(
      id: 'pop_iot_01',
      title: 'IoT for Beginners',
      description:
          'Build smart IoT projects and connect your ideas to the real world.',
      shortDescription:
          'Build smart IoT projects and connect your ideas to the real world.',
      instructor: 'IoT Specialist Lab',
      price: 899,
      priceText: '₹899',
      thumbnailUrl: '',
      assetPath: 'assets/images/courses/iot_house_3d.png',
      category: 'IoT & Smart Technology',
      level: 'BEGINNER',
      rating: 4.6,
      lessonsCount: 20,
      badgeText: 'BEGINNER',
      badgeColorHex: 0xFF3B82F6,
    ),
    CourseModel(
      id: 'pop_ai_01',
      title: 'AI Tools & Prompt Engineering',
      description: 'Master AI tools and learn powerful prompt engineering.',
      shortDescription:
          'Master AI tools and learn powerful prompt engineering.',
      instructor: 'AI Innovation Hub',
      price: 0,
      priceText: 'Free',
      thumbnailUrl: '',
      assetPath: 'assets/images/courses/advanced_robotics.png',
      category: 'AI',
      level: 'ALL LEVELS',
      rating: 4.8,
      lessonsCount: 15,
      isFreePreview: true,
      badgeText: 'FREE PREVIEW',
      badgeColorHex: 0xFF0D9488,
    ),
  ];

  static final List<CourseModel> newAndRecommendedCourses = [
    CourseModel(
      id: 'new_robotics_01',
      title: 'Senior Robotics Engineer',
      description:
          'Advance your robotics skills and work on complex real-world robot engineering projects.',
      shortDescription:
          'Advance your robotics skills and work on complex real-world robot engineering projects.',
      instructor: 'Advanced Robotics Lab',
      price: 1499,
      priceText: '₹1,499',
      thumbnailUrl: '',
      assetPath: 'assets/images/courses/senior_robotics_banner.png',
      category: 'Robotics',
      level: 'INTERMEDIATE',
      rating: 4.9,
      lessonsCount: 30,
      isKitIncluded: true,
      isNew: true,
      badgeText: 'NEW',
      badgeColorHex: 0xFF10B981,
    ),
    CourseModel(
      id: 'new_electronics_01',
      title: 'PCB Design & Manufacturing',
      description:
          'Learn PCB designing, fabrication and manufacturing.',
      shortDescription:
          'Learn PCB designing, fabrication and manufacturing.',
      instructor: 'Hardware Design Studio',
      price: 1199,
      priceText: '₹1,199',
      thumbnailUrl: '',
      assetPath: 'assets/images/courses/electronics_board_3d.png',
      category: 'Electronics',
      level: 'INTERMEDIATE',
      rating: 4.8,
      lessonsCount: 22,
      isNew: true,
      badgeText: 'NEW',
      badgeColorHex: 0xFF10B981,
    ),
    CourseModel(
      id: 'new_3d_01',
      title: '3D Printing for Beginners',
      description:
          'Learn 3D printing from basics and create amazing prints.',
      shortDescription:
          'Learn 3D printing from basics and create amazing prints.',
      instructor: '3D Studio Edukkit',
      price: 699,
      priceText: '₹699',
      thumbnailUrl: '',
      assetPath: 'assets/images/courses/junior_automation.png',
      category: '3D Printing',
      level: 'BEGINNER',
      rating: 4.7,
      lessonsCount: 16,
      isNew: true,
      badgeText: 'NEW',
      badgeColorHex: 0xFF10B981,
    ),
  ];

  /// Returns courses curated specifically for each Category view
  static List<CourseModel> getCoursesByCategory(String categoryName) {
    final name = categoryName.trim().toLowerCase();
    if (name.contains('robot')) {
      return [
        featuredCourse,
        CourseModel(
          id: 'cat_rob_02',
          title: 'Senior Robotics Engineer',
          description:
              'Advance your robotics skills and work on complex real-world robot engineering projects.',
          shortDescription:
              'Advance your robotics skills and work on complex real-world robot engineering projects.',
          instructor: 'Advanced Robotics Lab',
          price: 1499,
          priceText: '₹1,499',
          thumbnailUrl: '',
          assetPath: 'assets/images/courses/senior_robotics_banner.png',
          category: 'Robotics',
          level: 'INTERMEDIATE',
          rating: 4.9,
          lessonsCount: 30,
          isKitIncluded: true,
        ),
        CourseModel(
          id: 'cat_rob_03',
          title: 'Robotics Project Masterclass',
          description:
              'Build impressive robotics projects from scratch and become a confident robotics creator.',
          shortDescription:
              'Build impressive robotics projects from scratch and become a confident robotics creator.',
          instructor: 'Edukkit Masterclass Lab',
          price: 1999,
          priceText: '₹1,999',
          thumbnailUrl: '',
          assetPath: 'assets/images/courses/robotics_masterclass_banner.png',
          category: 'Robotics',
          level: 'ADVANCED',
          rating: 4.7,
          lessonsCount: 28,
          isKitIncluded: true,
        ),
      ];
    } else if (name.contains('electr')) {
      return [
        CourseModel(
          id: 'cat_elec_01',
          title: 'Electronics Fundamentals',
          description:
              'Understand electronic components, circuits & measurements through hands-on experiments.',
          shortDescription:
              'Understand electronic components, circuits & measurements through hands-on experiments.',
          instructor: 'Edukkit Circuits Team',
          price: 799,
          priceText: '₹799',
          thumbnailUrl: '',
          assetPath: 'assets/images/courses/electronics_board_3d.png',
          category: 'Electronics',
          level: 'BEGINNER',
          rating: 4.7,
          lessonsCount: 18,
          isKitIncluded: true,
        ),
        CourseModel(
          id: 'cat_elec_02',
          title: 'Basic Electronics for Beginners',
          description:
              'Master breadboards, LEDs, resistors & simple electronic circuits effortlessly.',
          shortDescription:
              'Master breadboards, LEDs, resistors & simple electronic circuits effortlessly.',
          instructor: 'Circuit Lab',
          price: 599,
          priceText: '₹599',
          thumbnailUrl: '',
          assetPath: 'assets/images/courses/electronics_fundamentals.png',
          category: 'Electronics',
          level: 'BEGINNER',
          rating: 4.6,
          lessonsCount: 16,
          isKitIncluded: true,
        ),
        CourseModel(
          id: 'cat_elec_03',
          title: 'PCB Design & Manufacturing',
          description:
              'Learn schematic design, PCB layout fabrication & SMD soldering step-by-step.',
          shortDescription:
              'Learn schematic design, PCB layout fabrication & SMD soldering step-by-step.',
          instructor: 'Hardware Studio',
          price: 1199,
          priceText: '₹1,199',
          thumbnailUrl: '',
          assetPath: 'assets/images/courses/electronics_board_3d.png',
          category: 'Electronics',
          level: 'INTERMEDIATE',
          rating: 4.8,
          lessonsCount: 22,
          isKitIncluded: false,
        ),
      ];
    } else if (name.contains('ai')) {
      return [
        CourseModel(
          id: 'cat_ai_01',
          title: 'AI Tools & Prompt Engineering',
          description:
              'Master AI tools and learn powerful prompt engineering strategies for real apps.',
          shortDescription:
              'Master AI tools and learn powerful prompt engineering strategies for real apps.',
          instructor: 'AI Hub',
          price: 0,
          priceText: 'Free',
          thumbnailUrl: '',
          assetPath: 'assets/images/courses/advanced_robotics.png',
          category: 'AI',
          level: 'ALL LEVELS',
          rating: 4.8,
          lessonsCount: 15,
          isFreePreview: true,
        ),
        CourseModel(
          id: 'cat_ai_02',
          title: 'AI + Robotics',
          description:
              'Integrate computer vision and neural networks with autonomous robotics.',
          shortDescription:
              'Integrate computer vision and neural networks with autonomous robotics.',
          instructor: 'RoboAI Studio',
          price: 1699,
          priceText: '₹1,699',
          thumbnailUrl: '',
          assetPath: 'assets/images/courses/senior_robotics_banner.png',
          category: 'AI',
          level: 'INTERMEDIATE',
          rating: 4.9,
          lessonsCount: 25,
          isKitIncluded: true,
        ),
      ];
    } else if (name.contains('3d') || name.contains('print')) {
      return [
        CourseModel(
          id: 'cat_3d_01',
          title: '3D Printing for Beginners',
          description:
              'Learn 3D slicing, filament setup & create your first physical 3D prints.',
          shortDescription:
              'Learn 3D slicing, filament setup & create your first physical 3D prints.',
          instructor: '3D Maker Lab',
          price: 699,
          priceText: '₹699',
          thumbnailUrl: '',
          assetPath: 'assets/images/courses/junior_automation.png',
          category: '3D Printing',
          level: 'BEGINNER',
          rating: 4.7,
          lessonsCount: 16,
          isKitIncluded: false,
        ),
        CourseModel(
          id: 'cat_3d_02',
          title: '3D Modeling with Fusion 360',
          description:
              'Design complex 3D parts & parametric CAD models ready for 3D printing.',
          shortDescription:
              'Design complex 3D parts & parametric CAD models ready for 3D printing.',
          instructor: 'Design Studio',
          price: 1299,
          priceText: '₹1,299',
          thumbnailUrl: '',
          assetPath: 'assets/images/courses/iot_house_3d.png',
          category: '3D Printing',
          level: 'INTERMEDIATE',
          rating: 4.8,
          lessonsCount: 20,
          isKitIncluded: false,
        ),
      ];
    } else {
      // Default: IoT & Smart Technology
      return [
        CourseModel(
          id: 'cat_iot_01',
          title: 'IoT for Beginners',
          description:
              'Build smart IoT projects and connect sensors & microcontrollers to the cloud.',
          shortDescription:
              'Build smart IoT projects and connect sensors & microcontrollers to the cloud.',
          instructor: 'IoT Specialist Lab',
          price: 899,
          priceText: '₹899',
          thumbnailUrl: '',
          assetPath: 'assets/images/courses/iot_house_3d.png',
          category: 'IoT & Smart Technology',
          level: 'BEGINNER',
          rating: 4.6,
          lessonsCount: 20,
          isKitIncluded: true,
        ),
        CourseModel(
          id: 'cat_iot_02',
          title: 'Home Automation',
          description:
              'Build Wi-Fi smart switches, environmental sensors & mobile app-controlled devices.',
          shortDescription:
              'Build Wi-Fi smart switches, environmental sensors & mobile app-controlled devices.',
          instructor: 'Smart Home Lab',
          price: 1399,
          priceText: '₹1,399',
          thumbnailUrl: '',
          assetPath: 'assets/images/courses/iot_home_automation.png',
          category: 'IoT & Smart Technology',
          level: 'INTERMEDIATE',
          rating: 4.8,
          lessonsCount: 24,
          isKitIncluded: true,
        ),
      ];
    }
  }
}
