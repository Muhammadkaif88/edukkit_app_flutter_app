import 'package:flutter/material.dart';
import 'course_detail_screen.dart';
import 'lessons_list_screen.dart';

class RoboticsCoursesScreen extends StatelessWidget {
  const RoboticsCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final courses = [
      {
        'title': 'Junior Automation Engineer',
        'description': 'Introduction to sensors and logic controllers.',
        'backgroundColor': const Color(0xFFE3F4FC),
        'icon': Icons.auto_awesome_mosaic,
        'price': 499.0,
        'originalPrice': 999.0,
        'projects': [
          {'day': 'Day 3', 'name': 'Blink LED', 'icon': Icons.lightbulb_outline, 'color': 0xFF4A40DF},
          {'day': 'Day 7', 'name': 'Smart Fan', 'icon': Icons.air, 'color': 0xFF00695C},
        ],
      },
      {
        'title': 'Junior Robotics Engineer',
        'description': 'Build your first walking robot from scratch.',
        'backgroundColor': const Color(0xFFFFF7E3),
        'icon': Icons.precision_manufacturing,
        'price': 699.0,
        'originalPrice': 1299.0,
        'projects': [
          {'day': 'Day 5', 'name': 'Walking Bot', 'icon': Icons.directions_walk, 'color': 0xFFE65100},
          {'day': 'Day 12', 'name': 'Obstacle Avoidance', 'icon': Icons.smart_toy_outlined, 'color': 0xFF6A1B9A},
        ],
      },
      {
        'title': 'Senior Robotics Engineer',
        'description': 'Advanced kinematics and AI-driven movement.',
        'backgroundColor': const Color(0xFFEFE8FF),
        'icon': Icons.memory,
        'price': 999.0,
        'originalPrice': 1999.0,
        'projects': [
          {'day': 'Day 10', 'name': 'Robot Arm', 'icon': Icons.hardware, 'color': 0xFFC62828},
          {'day': 'Day 20', 'name': 'Face Tracking', 'icon': Icons.face_retouching_natural, 'color': 0xFF5D3AC8},
        ],
      },
      {
        'title': 'Drone Pilot & Engineering',
        'description': 'Learn flight dynamics and drone assembly.',
        'backgroundColor': const Color(0xFFE3FCEF),
        'icon': Icons.airplanemode_active,
        'price': 1299.0,
        'originalPrice': 2499.0,
        'projects': [
          {'day': 'Day 8', 'name': 'Propeller Balance', 'icon': Icons.rotate_right, 'color': 0xFF2196F3},
          {'day': 'Day 15', 'name': 'First Flight', 'icon': Icons.flight_takeoff, 'color': 0xFF4CAF50},
        ],
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text("Robotics Courses", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildSmallCard(
              context: context,
              title: course['title'] as String,
              description: course['description'] as String,
              backgroundColor: course['backgroundColor'] as Color,
              icon: course['icon'] as IconData,
              price: course['price'] as double,
              originalPrice: course['originalPrice'] as double,
              projects: course['projects'] as List<Map<String, dynamic>>,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSmallCard({
    required BuildContext context,
    required String title,
    required String description,
    required Color backgroundColor,
    required IconData icon,
    required double price,
    required double originalPrice,
    required List<Map<String, dynamic>> projects,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CourseDetailScreen(
              title: title,
              subtitle: description,
              discountedPrice: price,
              originalPrice: originalPrice,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 100,
                  color: backgroundColor.withValues(alpha: 0.3),
                  child: Center(
                    child: Icon(icon, size: 40, color: backgroundColor.withValues(alpha: 1.0)),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D2D2D),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "BASIC",
                                style: TextStyle(
                                  color: Color(0xFF1E88E5),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF5D3AC8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                "Start Course",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
