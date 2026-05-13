import 'package:flutter/material.dart';
import 'course_detail_screen.dart';
import 'lessons_list_screen.dart';

class ElectronicsCoursesScreen extends StatelessWidget {
  const ElectronicsCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final courses = [
      {
        'title': 'Basic Electronics',
        'description': 'Master components like resistors, capacitors, and transistors.',
        'backgroundColor': const Color(0xFFFFF7E3),
        'icon': Icons.electrical_services,
        'price': 499.0,
        'originalPrice': 999.0,
        'projects': [
          {'day': 'Day 2', 'name': 'Circuit Board', 'icon': Icons.developer_board, 'color': 0xFFF5A623},
          {'day': 'Day 5', 'name': 'Signal Control', 'icon': Icons.alt_route, 'color': 0xFF4A90E2},
        ],
      },
      {
        'title': 'PCB Design Masterclass',
        'description': 'Design and print your own professional circuit boards.',
        'backgroundColor': const Color(0xFFE3F4FC),
        'icon': Icons.memory,
        'price': 899.0,
        'originalPrice': 1799.0,
        'projects': [
          {'day': 'Day 4', 'name': 'KiCad Basics', 'icon': Icons.category, 'color': 0xFF5D3AC8},
          {'day': 'Day 10', 'name': 'Custom Shield', 'icon': Icons.shield_outlined, 'color': 0xFFE65100},
        ],
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text("Electronics Courses", style: TextStyle(fontWeight: FontWeight.bold)),
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
                                color: const Color(0xFFF3E5F5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "ADVANCED",
                                style: TextStyle(
                                  color: Color(0xFF7B1FA2),
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
