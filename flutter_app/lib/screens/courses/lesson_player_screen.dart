import 'package:flutter/material.dart';

class LessonPlayerScreen extends StatefulWidget {
  final String courseTitle;
  final String initialLessonTitle;
  final List<Map<String, dynamic>> lessons;

  const LessonPlayerScreen({
    super.key,
    required this.courseTitle,
    required this.initialLessonTitle,
    required this.lessons,
  });

  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends State<LessonPlayerScreen> {
  late Map<String, dynamic> _currentLesson;

  @override
  void initState() {
    super.initState();
    _currentLesson = widget.lessons.firstWhere(
      (l) => l['title'] == widget.initialLessonTitle,
      orElse: () => widget.lessons.first,
    );
  }

  void _selectLesson(int index) {
    setState(() {
      _currentLesson = widget.lessons[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.courseTitle,
          style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Video Player Area ──────────────────────────────────────
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Placeholder for video
                  Image.network(
                    'https://images.unsplash.com/photo-1581092160562-40aa08e78837?w=800&auto=format&fit=crop',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    opacity: const AlwaysStoppedAnimation(0.6),
                  ),
                  const Icon(Icons.play_circle_fill, color: Colors.white, size: 64),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                      child: const Text('12:45', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Lesson Title & Info ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _currentLesson['title'],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 24),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    const Text('Module 1 • Lesson 3', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.description_outlined, size: 16),
                      label: const Text('Notes', style: TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ── Tab Bar (Description / Lessons / Discussion) ───────────
          const DefaultTabController(
            length: 3,
            child: Expanded(
              child: Column(
                children: [
                  TabBar(
                    labelColor: Color(0xFF4A40DF),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Color(0xFF4A40DF),
                    indicatorWeight: 3,
                    labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    tabs: [
                      Tab(text: 'Lessons'),
                      Tab(text: 'Description'),
                      Tab(text: 'Discussion'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _LessonListView(),
                        _DescriptionView(),
                        _DiscussionView(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonListView extends StatelessWidget {
  const _LessonListView();

  @override
  Widget build(BuildContext context) {
    // Sample lesson data
    final lessons = [
      {'title': 'Introduction to IoT', 'duration': '5:20', 'isCompleted': true, 'isLocked': false},
      {'title': 'Setting up your Kit', 'duration': '12:45', 'isCompleted': true, 'isLocked': false},
      {'title': 'Basic Circuitry', 'duration': '18:10', 'isCompleted': false, 'isLocked': false},
      {'title': 'Writing your first code', 'duration': '15:30', 'isCompleted': false, 'isLocked': false},
      {'title': 'Interfacing Sensors', 'duration': '22:00', 'isCompleted': false, 'isLocked': true},
      {'title': 'Cloud Integration', 'duration': '25:45', 'isCompleted': false, 'isLocked': true},
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: lessons.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 64),
      itemBuilder: (ctx, i) {
        final lesson = lessons[i];
        final isLocked = lesson['isLocked'] as bool;
        final isCompleted = lesson['isCompleted'] as bool;

        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isLocked ? Colors.grey.shade100 : const Color(0xFF4A40DF).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isLocked ? Icons.lock_outline : (isCompleted ? Icons.check : Icons.play_arrow),
              color: isLocked ? Colors.grey : const Color(0xFF4A40DF),
              size: 20,
            ),
          ),
          title: Text(
            lesson['title'] as String,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isLocked ? Colors.grey : Colors.black87,
            ),
          ),
          subtitle: Text(
            lesson['duration'] as String,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          trailing: isLocked 
            ? null 
            : const Icon(Icons.cloud_download_outlined, size: 20, color: Colors.grey),
          onTap: isLocked ? null : () {},
        );
      },
    );
  }
}

class _DescriptionView extends StatelessWidget {
  const _DescriptionView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('About this lesson', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Text(
            'In this lesson, we will cover the fundamentals of microcontroller architecture and how sensors interface with the CPU. You will learn about PWM, Digital I/O, and Analog inputs.',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 20),
          const Text('Resources', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          _resourceTile('Circuit Diagram.pdf', Icons.picture_as_pdf_outlined, Colors.red),
          _resourceTile('Source Code (Zip)', Icons.code_outlined, Colors.green),
          _resourceTile('Kit Documentation', Icons.description_outlined, Colors.blue),
        ],
      ),
    );
  }

  Widget _resourceTile(String label, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
          const Icon(Icons.download_outlined, size: 18, color: Colors.grey),
        ],
      ),
    );
  }
}

class _DiscussionView extends StatelessWidget {
  const _DiscussionView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _commentTile('M. Kaif', 'Sir, I am getting an error on line 42. Can you help?', '2 hours ago'),
              _commentTile('Admin', 'Make sure you have selected the correct Board in Tools menu.', '1 hour ago'),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Ask a question...',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const CircleAvatar(
                backgroundColor: Color(0xFF4A40DF),
                child: Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _commentTile(String name, String text, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: Text(name[0], style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 8),
                    Text(time, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(text, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
