import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sample classes
  final List<Map<String, dynamic>> _myClasses = [
    {
      'name': 'Robotics & IoT - Batch A',
      'students': 24,
      'progress': 0.68,
      'nextClass': 'Tomorrow, 10:00 AM',
      'color': 0xFF5D3AC8,
      'icon': Icons.precision_manufacturing_outlined,
    },
    {
      'name': 'Home Automation Course',
      'students': 18,
      'progress': 0.42,
      'nextClass': 'Today, 4:00 PM',
      'color': 0xFF00695C,
      'icon': Icons.home_outlined,
    },
    {
      'name': 'AI + IoT - Advanced',
      'students': 12,
      'progress': 0.85,
      'nextClass': 'Thursday, 11:00 AM',
      'color': 0xFF6A1B9A,
      'icon': Icons.smart_toy_outlined,
    },
  ];

  // Sample students
  final List<Map<String, dynamic>> _students = [
    {'name': 'Arjun Sharma', 'course': 'Robotics & IoT', 'progress': 0.80, 'avatar': 'AS'},
    {'name': 'Priya Nair', 'course': 'Home Automation', 'progress': 0.55, 'avatar': 'PN'},
    {'name': 'Rahul Menon', 'course': 'AI + IoT', 'progress': 0.90, 'avatar': 'RM'},
    {'name': 'Sneha Pillai', 'course': 'Robotics & IoT', 'progress': 0.30, 'avatar': 'SP'},
    {'name': 'Vikram Das', 'course': 'AI + IoT', 'progress': 0.70, 'avatar': 'VD'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 190,
            pinned: true,
            backgroundColor: const Color(0xFF00897B),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF00BFA5), Color(0xFF00695C)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 44),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.white,
                              backgroundImage: auth.userPhotoUrl != null
                                  ? NetworkImage(auth.userPhotoUrl!)
                                  : null,
                              child: auth.userPhotoUrl == null
                                  ? const Icon(Icons.person, color: Color(0xFF00695C), size: 30)
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Welcome back,',
                                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                                Text(auth.userName,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('TEACHER',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Quick stats
                        Row(
                          children: [
                            _quickStat('54', 'Students'),
                            const SizedBox(width: 20),
                            _quickStat('3', 'Classes'),
                            const SizedBox(width: 20),
                            _quickStat('12', 'Lessons'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(text: 'My Classes'),
                Tab(text: 'Students'),
                Tab(text: 'Upload'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildMyClasses(),
            _buildStudents(),
            _buildUpload(),
          ],
        ),
      ),
    );
  }

  Widget _quickStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  // ── Tab 1: My Classes ─────────────────────────────────────────────
  Widget _buildMyClasses() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Today's schedule card
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00BFA5), Color(0xFF00695C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: const Color(0xFF00BFA5).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.today_outlined, color: Colors.white, size: 32),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Today's Class", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const Text('Home Automation Course',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    const Text('4:00 PM — 18 Students',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF00695C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text('Start', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ),

        const Text('All Classes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
        const SizedBox(height: 12),

        ..._myClasses.map((cls) => _buildClassCard(cls)),

        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => _showCreateClassDialog(),
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Create New Class'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF00695C),
            side: const BorderSide(color: Color(0xFF00695C)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildClassCard(Map<String, dynamic> cls) {
    final color = Color(cls['color'] as int);
    final progress = cls['progress'] as double;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
                  child: Icon(cls['icon'] as IconData, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cls['name'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A1A2E))),
                      const SizedBox(height: 2),
                      Row(children: [
                        Icon(Icons.people_outline, size: 13, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text('${cls['students']} Students',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      ]),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) {},
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit Class')),
                    const PopupMenuItem(value: 'view', child: Text('View Students')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                  child: const Icon(Icons.more_vert, color: Colors.grey),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Progress: ${(progress * 100).toInt()}%',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
                    Row(children: [
                      Icon(Icons.schedule_outlined, size: 13, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(cls['nextClass'] as String,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    ]),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: color.withOpacity(0.5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                        ),
                        child: Text('View Students', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                        ),
                        child: const Text('Add Lesson', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 2: Students ───────────────────────────────────────────────
  Widget _buildStudents() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Search
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search students...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('All Students', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
        const SizedBox(height: 12),
        ..._students.map((s) => _buildStudentCard(s)),
      ],
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final progress = student['progress'] as double;
    final pct = (progress * 100).toInt();
    final Color progressColor = pct >= 80
        ? const Color(0xFF4CAF50)
        : pct >= 50
            ? const Color(0xFFFFC107)
            : const Color(0xFFF44336);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF00695C).withOpacity(0.1),
            child: Text(student['avatar'] as String,
                style: const TextStyle(color: Color(0xFF00695C), fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student['name'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A1A2E))),
                Text(student['course'] as String,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                const SizedBox(height: 6),
                Row(children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 5,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('$pct%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: progressColor)),
                ]),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.message_outlined, color: Color(0xFF00695C)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // ── Tab 3: Upload Content ─────────────────────────────────────────
  Widget _buildUpload() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Upload Content', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.1,
            children: [
              _buildUploadTile('Video Lesson', Icons.video_library_outlined, const Color(0xFF5D3AC8)),
              _buildUploadTile('PDF Notes', Icons.picture_as_pdf_outlined, const Color(0xFFE65100)),
              _buildUploadTile('Assignment', Icons.assignment_outlined, const Color(0xFF2196F3)),
              _buildUploadTile('Live Class', Icons.live_tv_outlined, const Color(0xFF4CAF50)),
              _buildUploadTile('Quiz', Icons.quiz_outlined, const Color(0xFFFFC107)),
              _buildUploadTile('Announcement', Icons.campaign_outlined, const Color(0xFFEC407A)),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Recent Uploads', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 12),
          _buildRecentUpload('Module 5 - Sensor Integration.mp4', 'Video', '128 MB', Icons.play_circle_outline, const Color(0xFF5D3AC8)),
          _buildRecentUpload('Week 3 Notes.pdf', 'PDF', '2.4 MB', Icons.picture_as_pdf_outlined, const Color(0xFFE65100)),
          _buildRecentUpload('Assignment 2 - IoT Project', 'Assignment', 'Due: May 20', Icons.assignment_outlined, const Color(0xFF2196F3)),
        ],
      ),
    );
  }

  Widget _buildUploadTile(String label, IconData icon, Color color) {
    return InkWell(
      onTap: () => _showUploadSnack(label),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 3))],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 4),
            Text('Upload', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentUpload(String name, String type, String meta, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('$type  •  $meta', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  void _showUploadSnack(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Upload $type — coming soon!'),
        backgroundColor: const Color(0xFF00695C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showCreateClassDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Create New Class', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Class creation form coming soon!'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00695C)),
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
