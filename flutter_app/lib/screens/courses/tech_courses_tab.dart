import 'package:flutter/material.dart';
import 'robotics_courses_screen.dart';
import 'iot_courses_screen.dart';

class TechCoursesTab extends StatelessWidget {
  const TechCoursesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Tech Courses',
                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
              ),
              background: Container(color: Colors.white),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildCategoryCard(
                  context,
                  title: "Robotics Courses",
                  subtitle: "Build sensors, controllers, and mechanical parts",
                  icon: Icons.precision_manufacturing,
                  color: const Color(0xFF4A40DF),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RoboticsCoursesScreen()),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _buildCategoryCard(
                  context,
                  title: "AI & IoT Courses",
                  subtitle: "Learn cloud integration and smart logic",
                  icon: Icons.wifi,
                  color: const Color(0xFF67C275),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const IotCoursesScreen()),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _buildCategoryCard(
                  context,
                  title: "3D Printing & Design",
                  subtitle: "Create physical prototypes and models",
                  icon: Icons.print,
                  color: const Color(0xFFFCAE3D),
                  onTap: () {
                    // Navigate to 3D print screen (if exists)
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: color.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}
