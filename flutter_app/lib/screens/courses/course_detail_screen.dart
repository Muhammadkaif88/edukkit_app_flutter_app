import 'package:flutter/material.dart';
import 'lesson_player_screen.dart';
import 'lessons_list_screen.dart';

class CourseDetailScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final String level;
  final String version;
  final double originalPrice;
  final double discountedPrice;
  final List<Map<String, dynamic>> buildProjects;

  const CourseDetailScreen({
    super.key,
    required this.title,
    required this.subtitle,
    this.level = 'Beginner Level',
    this.version = 'v2.0',
    this.originalPrice = 999,
    this.discountedPrice = 499,
    this.buildProjects = const [],
  });

  @override
  Widget build(BuildContext context) {
    final discount = (((originalPrice - discountedPrice) / originalPrice) * 100).round();
    
    final projectsList = buildProjects.isNotEmpty ? buildProjects : [
      {'day': 'Day 7', 'name': 'Automatic Emergency Light', 'icon': Icons.lightbulb_outline, 'color': 0xFF4A40DF},
      {'day': 'Day 8', 'name': 'Warning Light', 'icon': Icons.warning_amber_outlined, 'color': 0xFFE65100},
      {'day': 'Day 9', 'name': 'Digital Piano', 'icon': Icons.piano, 'color': 0xFF00695C},
      {'day': 'Day 14+', 'name': 'Robotics Projects', 'icon': Icons.precision_manufacturing_outlined, 'color': 0xFF6A1B9A},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.favorite_border, color: Colors.deepPurple), onPressed: () {}),
          IconButton(icon: const Icon(Icons.share_outlined, color: Colors.deepPurple), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Banner ──────────────────────────────────
            _buildHeroBanner(),
            
            // ── Syllabus & Brochure ──────────────────────────
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.menu_book_rounded,
                      color: const Color(0xFF6C63FF),
                      title: "Course Syllabus",
                      subtitle: "View all modules & lessons",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.picture_as_pdf_rounded,
                      color: const Color(0xFFFF6B6B),
                      title: "Course Brochure",
                      subtitle: "Download course brochure",
                    ),
                  ),
                ],
              ),
            ),

            // ── Stats Row ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(Icons.calendar_month, "25", "Days", Colors.deepPurple),
                    _buildStatItem(Icons.play_circle_fill, "40+", "Video Lessons", Colors.blue),
                    _buildStatItem(Icons.settings, "10+", "Projects", Colors.green),
                    _buildStatItem(Icons.verified, "Included", "Certificate", Colors.orange),
                  ],
                ),
              ),
            ),

            // ── What you will build ──────────────────────────
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("What you will build", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("View All >", style: TextStyle(color: Colors.deepPurple, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 16),
                scrollDirection: Axis.horizontal,
                itemCount: projectsList.length,
                itemBuilder: (context, index) => _buildProjectCard(projectsList[index]),
              ),
            ),

            // ── What's included ──────────────────────────────
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text("What's included", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _buildIncludedList(),

            const SizedBox(height: 120), // Padding for bottom bar
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, discount),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF1B2459), Color(0xFF3B4A9F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Background Decorative Pattern or Image Placeholder
          Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.1,
              child: Icon(Icons.electrical_services, size: 200, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bar_chart, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(level, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const Spacer(),
                const Text(
                  "Electronics",
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                Text(
                  "1st Month Course",
                  style: TextStyle(color: Colors.amber.shade600, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Learn Basic Electronics from\nScratch & Build Real Projects",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 24,
                      child: Stack(
                        children: List.generate(4, (i) => Positioned(
                          left: i * 15.0,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(radius: 10, backgroundColor: Colors.grey.shade300),
                          ),
                        )),
                      ),
                    ),
                    const Text("5K+ Students Enrolled", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(version, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({required IconData icon, required Color color, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                Text(subtitle, style: const TextStyle(fontSize: 9, color: Colors.black54)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.black26),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54)),
      ],
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Stack(
                children: [
                  Center(child: Icon(project['icon'] as IconData, size: 40, color: Colors.grey)),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(8)),
                      child: Text(project['day'] as String, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(project['name'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildIncludedList() {
    final items = [
      {"icon": Icons.play_lesson, "title": "High Quality\nVideo Lessons"},
      {"icon": Icons.description, "title": "PDF Notes &\nResources"},
      {"icon": Icons.code, "title": "Source Code &\nCircuit Diagram"},
      {"icon": Icons.support_agent, "title": "AI Mentor\nSupport"},
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        children: items.map((item) => Container(
          width: 100,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(item['icon'] as IconData, color: Colors.deepPurple, size: 24),
              const SizedBox(height: 8),
              Text(item['title'] as String, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500)),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, int discount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Course Fee", style: TextStyle(fontSize: 11, color: Colors.black54)),
              Row(
                children: [
                  Text("₹${discountedPrice.toInt()}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                  const SizedBox(width: 8),
                  Text("₹${originalPrice.toInt()}", style: const TextStyle(fontSize: 14, color: Colors.black26, decoration: TextDecoration.lineThrough)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text("$discount% OFF", style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.orange, Colors.deepOrange]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LessonsListScreen(
                          courseTitle: title,
                          lessons: const [
                            {'title': 'Introduction to the Course'},
                            {'title': 'Understanding the Basics'},
                            {'title': 'Unboxing the Kit'},
                            {'title': 'First Project: LED Blink'},
                            {'title': 'Circuit Logic'},
                            {'title': 'Final Assessment'},
                          ],
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: const Center(
                    child: Text("Free Trial", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
