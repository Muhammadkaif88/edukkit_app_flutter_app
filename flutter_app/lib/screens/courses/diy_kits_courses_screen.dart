import 'package:flutter/material.dart';
import 'course_detail_screen.dart';
import 'lessons_list_screen.dart';

class DiyKitsCoursesScreen extends StatelessWidget {
  const DiyKitsCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final kits = [
      {
        'title': 'Solar Light Kit',
        'description': 'Build your own sustainable emergency light source.',
        'backgroundColor': const Color(0xFFE3FCEF),
        'icon': Icons.wb_sunny_outlined,
        'price': 299.0,
        'originalPrice': 599.0,
        'projects': [
          {'day': 'Step 1', 'name': 'Solar Panel Wiring', 'icon': Icons.solar_power, 'color': 0xFF00BFA5},
          {'day': 'Step 2', 'name': 'Battery Setup', 'icon': Icons.battery_charging_full, 'color': 0xFF4A90E2},
        ],
      },
      {
        'title': 'Obstacle Avoiding Robot',
        'description': 'Hands-on project using ultrasonic sensors and Arduino.',
        'backgroundColor': const Color(0xFFEFE8FF),
        'icon': Icons.precision_manufacturing,
        'price': 1299.0,
        'originalPrice': 2499.0,
        'projects': [
          {'day': 'Step 1', 'name': 'Chassis Assembly', 'icon': Icons.build, 'color': 0xFF5D3AC8},
          {'day': 'Step 2', 'name': 'Coding the Logic', 'icon': Icons.code, 'color': 0xFFE65100},
        ],
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text("DIY Kit Courses", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: kits.length,
        itemBuilder: (context, index) {
          final kit = kits[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildSmallCard(
              context: context,
              title: kit['title'] as String,
              description: kit['description'] as String,
              backgroundColor: kit['backgroundColor'] as Color,
              icon: kit['icon'] as IconData,
              price: kit['price'] as double,
              originalPrice: kit['originalPrice'] as double,
              projects: kit['projects'] as List<Map<String, dynamic>>,
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
                                color: const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "KITS",
                                style: TextStyle(
                                  color: Color(0xFFEF6C00),
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
