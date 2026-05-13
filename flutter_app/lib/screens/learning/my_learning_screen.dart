import 'package:flutter/material.dart';

class MyLearningScreen extends StatefulWidget {
  const MyLearningScreen({super.key});

  @override
  State<MyLearningScreen> createState() => _MyLearningScreenState();
}

class _MyLearningScreenState extends State<MyLearningScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Sample Data ─────────────────────────────────────────────────
  final List<Map<String, dynamic>> _courses = [
    {
      'title': 'IoT Development',
      'teacher': 'Kaif Sir',
      'progress': 0.75,
      'color': const Color(0xFF4A40DF),
      'icon': Icons.wifi_tethering,
      'lessons': 24,
      'completed': 18,
    },
    {
      'title': 'Robotics & IoT',
      'teacher': 'Rahul Sir',
      'progress': 0.45,
      'color': const Color(0xFF00695C),
      'icon': Icons.precision_manufacturing_outlined,
      'lessons': 30,
      'completed': 13,
    },
    {
      'title': 'Home Automation',
      'teacher': 'Arjun Sir',
      'progress': 1.0,
      'color': const Color(0xFFE65100),
      'icon': Icons.home_outlined,
      'lessons': 20,
      'completed': 20,
    },
    {
      'title': 'AI + IoT',
      'teacher': 'Priya Ma\'am',
      'progress': 0.2,
      'color': const Color(0xFF6A1B9A),
      'icon': Icons.psychology_outlined,
      'lessons': 40,
      'completed': 8,
    },
  ];

  final List<Map<String, dynamic>> _savedVideos = [
    {'title': 'Intro to Arduino Mega', 'course': 'Robotics & IoT', 'duration': '14:32'},
    {'title': 'MQTT Protocol Basics', 'course': 'IoT Development', 'duration': '22:08'},
    {'title': 'ESP32 Wi-Fi Setup', 'course': 'Home Automation', 'duration': '18:45'},
  ];

  final List<Map<String, dynamic>> _notes = [
    {'title': 'Arduino Basics Notes.pdf', 'course': 'Robotics & IoT', 'size': '1.2 MB', 'bookmarked': true},
    {'title': 'MQTT Protocol.pdf', 'course': 'IoT Development', 'size': '850 KB', 'bookmarked': false},
    {'title': 'Sensor Integration.pdf', 'course': 'Home Automation', 'size': '2.1 MB', 'bookmarked': true},
    {'title': 'AI Overview.pdf', 'course': 'AI + IoT', 'size': '3.4 MB', 'bookmarked': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A40DF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Learning',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Enrolled'),
            Tab(text: 'Saved Videos'),
            Tab(text: 'Notes'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEnrolled(),
          _buildSavedVideos(),
          _buildNotes(),
          _buildCompleted(),
        ],
      ),
    );
  }

  // ── Tab 1: Enrolled Courses ─────────────────────────────────────
  Widget _buildEnrolled() {
    final enrolled =
        _courses.where((c) => (c['progress'] as double) < 1.0).toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _statRow(enrolled.length, _courses.length),
        const SizedBox(height: 16),
        ...enrolled.map((c) => _courseCard(c)),
      ],
    );
  }

  Widget _statRow(int active, int total) {
    return Row(
      children: [
        _statChip('$active Active', Icons.play_circle_outline,
            const Color(0xFF4A40DF)),
        const SizedBox(width: 10),
        _statChip('$total Total', Icons.school_outlined,
            const Color(0xFF00695C)),
      ],
    );
  }

  Widget _statChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _courseCard(Map<String, dynamic> course) {
    final progress = course['progress'] as double;
    final pct = (progress * 100).toInt();
    final color = course['color'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Thumbnail
          Container(
            height: 110,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.65)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(course['icon'] as IconData,
                          color: Colors.white, size: 32),
                      const Spacer(),
                      Text('${course['completed']}/${course['lessons']} lessons',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course['title'] as String,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person_outline,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('Teacher: ${course['teacher']}',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$pct% Completed',
                        style: TextStyle(
                            color: pct == 100
                                ? const Color(0xFF00695C)
                                : color,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                    Text('${course['completed']}/${course['lessons']}',
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        pct == 100
                            ? const Color(0xFF00695C)
                            : color),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      pct == 100 ? 'Review Course' : 'Continue Learning',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 2: Saved Videos ─────────────────────────────────────────
  Widget _buildSavedVideos() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _savedVideos.length,
      itemBuilder: (_, i) {
        final v = _savedVideos[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF4A40DF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.play_circle_filled,
                  color: Color(0xFF4A40DF), size: 30),
            ),
            title: Text(v['title'] as String,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(v['course'] as String,
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 12)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined,
                        size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(v['duration'] as String,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.bookmark,
                  color: Color(0xFF4A40DF)),
              onPressed: () {},
            ),
          ),
        );
      },
    );
  }

  // ── Tab 3: Notes ────────────────────────────────────────────────
  Widget _buildNotes() {
    final notesList = List<Map<String, dynamic>>.from(_notes);
    return StatefulBuilder(
      builder: (_, setSS) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notesList.length,
        itemBuilder: (_, i) {
          final n = notesList[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFB71C1C).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.picture_as_pdf,
                    color: Color(0xFFB71C1C), size: 26),
              ),
              title: Text(n['title'] as String,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(n['course'] as String,
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 12)),
                  Text(n['size'] as String,
                      style: const TextStyle(
                          fontSize: 11, color: Colors.grey)),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      (n['bookmarked'] as bool)
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: (n['bookmarked'] as bool)
                          ? const Color(0xFF4A40DF)
                          : Colors.grey,
                      size: 22,
                    ),
                    onPressed: () =>
                        setSS(() => n['bookmarked'] = !(n['bookmarked'] as bool)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.download_outlined,
                        color: Color(0xFF00695C), size: 22),
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Download starting...'),
                        backgroundColor: Color(0xFF00695C),
                        behavior: SnackBarBehavior.floating,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Tab 4: Completed ────────────────────────────────────────────
  Widget _buildCompleted() {
    final done =
        _courses.where((c) => (c['progress'] as double) >= 1.0).toList();
    if (done.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined,
                size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('No Completed Courses Yet',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
            const SizedBox(height: 8),
            Text('Keep learning to unlock achievements!',
                style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: done.map((c) => _courseCard(c)).toList(),
    );
  }
}
