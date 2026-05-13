import 'package:flutter/material.dart';

class MyCoursesTab extends StatelessWidget {
  const MyCoursesTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock purchased courses
    final List<Map<String, dynamic>> purchasedCourses = [
      {
        'title': 'Junior Automation Engineer',
        'progress': 0.75,
        'image': Icons.auto_awesome_mosaic,
        'color': const Color(0xFF4A40DF),
        'lessons': '15/20 Lessons'
      },
      {
        'title': 'IoT Home Automation',
        'progress': 0.4,
        'image': Icons.wifi,
        'color': const Color(0xFF67C275),
        'lessons': '4/10 Lessons'
      },
      {
        'title': 'Advanced Robotics kinematics',
        'progress': 0.1,
        'image': Icons.memory,
        'color': const Color(0xFFFCAE3D),
        'lessons': '1/12 Lessons'
      },
    ];

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
                'My Courses',
                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
              ),
              background: Container(color: Colors.white),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: purchasedCourses.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.school_outlined, size: 80, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          const Text(
                            'No courses purchased yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to Tech Courses (handled by parent HomeScreen)
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A40DF),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Explore Courses', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final course = purchasedCourses[index];
                        return _buildPurchasedCourseCard(course);
                      },
                      childCount: purchasedCourses.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchasedCourseCard(Map<String, dynamic> course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: (course['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(course['image'] as IconData, color: course['color'] as Color, size: 40),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  course['lessons'],
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: course['progress'] as double,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(course['color'] as Color),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${((course['progress'] as double) * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: course['color'] as Color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
