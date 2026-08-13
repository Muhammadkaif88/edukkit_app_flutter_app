import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/course_model.dart';
import 'course_playlist_screen.dart';

/// A reusable course page. Content is deliberately kept local and data driven
/// until it is supplied by the Admin/API layer.
class CourseDetailScreen extends StatelessWidget {
  final CourseModel course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final details = CourseDetailContent.forCourse(course);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
        ),
        title: Text(
          course.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w800,
          ),
        ),
        actions: const [
          _HeaderAction(icon: Icons.favorite_border_rounded),
          _HeaderAction(icon: Icons.share_outlined),
          SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 112),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Hero(course: course, details: details),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _ActionTile(
                    icon: Icons.menu_book_rounded,
                    color: const Color(0xFF4F46E5),
                    title: 'Course Syllabus',
                    subtitle: '${details.modules.length} modules • ${course.lessonsCount} lessons',
                    onTap: () => _showSyllabus(context, details),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _ActionTile(
                    icon: Icons.picture_as_pdf_rounded,
                    color: const Color(0xFFEA580C),
                    title: 'Course Brochure',
                    subtitle: 'View course overview',
                    onTap: () => _showBrochure(context),
                  )),
                ],
              ),
              const SizedBox(height: 18),
              _StatsCard(course: course, details: details),
              const _SectionTitle('What you will build'),
              SizedBox(
                height: 166,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: details.projects.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, index) => _ProjectCard(
                    project: details.projects[index],
                    imagePath: course.assetPath,
                  ),
                ),
              ),
              const _SectionTitle("What's included"),
              _IncludedGrid(items: details.included),
              const _SectionTitle('About this course'),
              Text(details.overview, style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF475569), fontSize: 13, height: 1.55, fontWeight: FontWeight.w500,
              )),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomCta(course: course, details: details),
    );
  }

  void _showSyllabus(BuildContext context, CourseDetailContent details) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SyllabusSheet(details: details),
    );
  }

  void _showBrochure(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Course brochure will be available here after it is uploaded by Admin.'),
      behavior: SnackBarBehavior.floating,
    ));
  }
}

class CourseDetailContent {
  final String duration;
  final String students;
  final String version;
  final String overview;
  final List<String> modules;
  final List<String> trialLessons;
  final List<CourseProject> projects;
  final List<IncludedItem> included;

  const CourseDetailContent({
    required this.duration, required this.students, required this.version,
    required this.overview, required this.modules, required this.trialLessons,
    required this.projects, required this.included,
  });

  factory CourseDetailContent.forCourse(CourseModel course) {
    final category = course.category.toLowerCase();
    final isRobotics = category.contains('robot');
    final isElectronics = category.contains('electr');
    final isAi = category == 'ai';
    final isPrinting = category.contains('3d');
    final accent = isAi ? 0xFF0284C7 : isElectronics ? 0xFFEA580C : isPrinting ? 0xFFDB2777 : isRobotics ? 0xFF7C3AED : 0xFF0D9488;
    final focus = isAi ? 'AI-powered ideas' : isElectronics ? 'working circuits' : isPrinting ? 'print-ready creations' : isRobotics ? 'smart robots' : 'connected smart devices';
    final baseProjects = isAi
        ? ['Prompt library', 'AI study assistant', 'Vision experiment']
        : isElectronics
            ? ['LED control board', 'Smart alarm', 'Mini digital instrument']
            : isPrinting
                ? ['Custom keychain', 'Desk organiser', 'Prototype model']
                : isRobotics
                    ? ['Line follower robot', 'Obstacle detector', 'Smart rover']
                    : ['Weather station', 'Smart light', 'Home control panel'];
    final icons = isAi ? [Icons.auto_awesome_rounded, Icons.chat_bubble_outline_rounded, Icons.visibility_rounded]
        : isElectronics ? [Icons.lightbulb_outline_rounded, Icons.notifications_active_outlined, Icons.piano_rounded]
        : isPrinting ? [Icons.view_in_ar_rounded, Icons.inventory_2_outlined, Icons.architecture_rounded]
        : isRobotics ? [Icons.smart_toy_rounded, Icons.sensors_rounded, Icons.precision_manufacturing_rounded]
        : [Icons.cloud_outlined, Icons.lightbulb_outline_rounded, Icons.home_outlined];
    return CourseDetailContent(
      duration: '${(course.lessonsCount / 2).ceil()} days',
      students: '${course.rating >= 4.8 ? '2.5K+' : '1K+'} learners',
      version: 'v1.0',
      overview: '${course.title} is a practical, guided course designed to help learners build confidence through small wins. Explore concepts clearly, follow step-by-step lessons, and finish with $focus you can proudly share.',
      modules: ['Getting started', 'Core concepts', 'Guided builds', 'Challenge project'],
      trialLessons: ['Welcome to ${course.title}', 'How this course works', 'Your first hands-on activity'],
      projects: List.generate(3, (i) => CourseProject(
        day: 'Build ${i + 1}', name: baseProjects[i], icon: icons[i], color: Color(accent),
      )),
      included: const [
        IncludedItem(Icons.play_circle_outline_rounded, 'Video lessons'),
        IncludedItem(Icons.description_outlined, 'Notes & resources'),
        IncludedItem(Icons.code_rounded, 'Project files'),
        IncludedItem(Icons.support_agent_rounded, 'Mentor support'),
      ],
    );
  }
}

class CourseProject {
  final String day;
  final String name;
  final IconData icon;
  final Color color;
  const CourseProject({required this.day, required this.name, required this.icon, required this.color});
}

class IncludedItem {
  final IconData icon;
  final String label;
  const IncludedItem(this.icon, this.label);
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  const _HeaderAction({required this.icon});
  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('This option will be connected soon.'))),
    icon: Icon(icon, color: const Color(0xFF4F46E5), size: 22),
  );
}

class _Hero extends StatelessWidget {
  final CourseModel course;
  final CourseDetailContent details;
  const _Hero({required this.course, required this.details});
  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 1.62,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(fit: StackFit.expand, children: [
        if (course.assetPath != null && course.assetPath!.isNotEmpty)
          Image.asset(course.assetPath!, fit: BoxFit.cover, errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFF312E81)))
        else const ColoredBox(color: Color(0xFF312E81)),
        const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.centerLeft, end: Alignment.centerRight,
          colors: [Color(0xE610172A), Color(0xA610172A), Color(0x1010172A)],
        ))),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: 7, children: [_Pill(label: course.level), if (course.isKitIncluded) const _Pill(label: 'KIT INCLUDED')]),
            const Spacer(),
            Text(course.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w800, height: 1.08)),
            const SizedBox(height: 6),
            Text(course.shortDescription, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(color: const Color(0xFFE2E8F0), fontSize: 12, height: 1.35, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Row(children: [const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 17), const SizedBox(width: 3), Text('${course.rating}  •  ${details.students}', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700))]),
          ]),
        ),
      ]),
    ),
  );
}

class _Pill extends StatelessWidget {
  final String label;
  const _Pill({required this.label});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(7), border: Border.all(color: Colors.white.withValues(alpha: 0.22))),
    child: Text(label.toUpperCase(), style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
  );
}

class _ActionTile extends StatelessWidget {
  final IconData icon; final Color color; final String title; final String subtitle; final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.color, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white, borderRadius: BorderRadius.circular(17),
    child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(17), child: Padding(
      padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 20, color: color)),
        const SizedBox(height: 10), Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
        const SizedBox(height: 3), Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFF64748B))),
      ]),
    )),
  );
}

class _StatsCard extends StatelessWidget {
  final CourseModel course; final CourseDetailContent details;
  const _StatsCard({required this.course, required this.details});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Color(0x080F172A), blurRadius: 14, offset: Offset(0, 5))]),
    child: Row(children: [
      _Stat(icon: Icons.calendar_today_rounded, value: details.duration, label: 'Duration', color: const Color(0xFF4F46E5)),
      _Stat(icon: Icons.play_circle_outline_rounded, value: '${course.lessonsCount}', label: 'Lessons', color: const Color(0xFF0284C7)),
      _Stat(icon: Icons.construction_rounded, value: '${details.projects.length}+', label: 'Builds', color: const Color(0xFF16A34A)),
      const _Stat(icon: Icons.workspace_premium_rounded, value: 'Yes', label: 'Certificate', color: Color(0xFFEA580C)),
    ]),
  );
}

class _Stat extends StatelessWidget {
  final IconData icon; final String value; final String label; final Color color;
  const _Stat({required this.icon, required this.value, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Icon(icon, size: 20, color: color), const SizedBox(height: 7), Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
    const SizedBox(height: 2), Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 9.5, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
  ]));
}

class _SectionTitle extends StatelessWidget {
  final String text; const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(top: 25, bottom: 12), child: Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))));
}

class _ProjectCard extends StatelessWidget {
  final CourseProject project;
  final String? imagePath;

  const _ProjectCard({required this.project, this.imagePath});
  @override
  Widget build(BuildContext context) => Container(
    width: 142,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFEFF2F6)),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        child: Stack(fit: StackFit.expand, children: [
          if (imagePath != null && imagePath!.isNotEmpty)
            Image.asset(imagePath!, fit: BoxFit.cover, errorBuilder: (_, _, _) => _projectFallback())
          else
            _projectFallback(),
          DecoratedBox(decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.12))),
          Positioned(
            left: 9,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(color: const Color(0xFF4F46E5), borderRadius: BorderRadius.circular(7)),
              child: Text(project.day, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800)),
            ),
          ),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.all(11),
        child: Text(project.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 12, height: 1.2, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
      ),
    ]),
  );

  Widget _projectFallback() => ColoredBox(
    color: project.color.withValues(alpha: 0.14),
    child: Center(child: Icon(project.icon, color: project.color, size: 38)),
  );
}

class _IncludedGrid extends StatelessWidget {
  final List<IncludedItem> items; const _IncludedGrid({required this.items});
  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: items.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 3.35, crossAxisSpacing: 10, mainAxisSpacing: 10),
    itemBuilder: (_, i) => Container(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: Row(children: [
      Icon(items[i].icon, color: const Color(0xFF4F46E5), size: 20), const SizedBox(width: 9), Expanded(child: Text(items[i].label, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF334155)))),
    ])),
  );
}

class _BottomCta extends StatelessWidget {
  final CourseModel course; final CourseDetailContent details;
  const _BottomCta({required this.course, required this.details});
  @override
  Widget build(BuildContext context) {
    // Until Admin supplies pricing, zero-priced placeholder courses use a
    // realistic introductory fee rather than displaying "Free course".
    final fee = course.price > 0 ? course.price : 499.0;
    final originalFee = (fee * 2).roundToDouble();
    final discount = (((originalFee - fee) / originalFee) * 100).round();

    return SafeArea(top: false, child: Container(
    padding: const EdgeInsets.fromLTRB(18, 12, 18, 14), decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Color(0x180F172A), blurRadius: 18, offset: Offset(0, -5))]),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text('Course fee', style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
        Row(children: [
          Text('₹${fee.toInt()}', style: GoogleFonts.plusJakartaSans(fontSize: 19, fontWeight: FontWeight.w800, color: const Color(0xFF4F46E5))),
          const SizedBox(width: 6),
          Text('₹${originalFee.toInt()}', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF94A3B8), decoration: TextDecoration.lineThrough)),
        ]),
        const SizedBox(height: 3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(5)),
          child: Text('$discount% OFF', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFF15803D))),
        ),
      ])),
      const SizedBox(width: 12),
      Expanded(flex: 2, child: SizedBox(height: 52, child: ElevatedButton.icon(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CoursePlaylistScreen(course: course))),
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        icon: const Icon(Icons.play_arrow_rounded, size: 20), label: Text('Start Free Trial', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800)),
      ))),
    ]),
  ));
  }
}

class _SyllabusSheet extends StatelessWidget {
  final CourseDetailContent details;

  const _SyllabusSheet({required this.details});

  @override
  Widget build(BuildContext context) {
    final moduleTiles = <Widget>[];
    for (var index = 0; index < details.modules.length; index++) {
      moduleTiles.add(
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            radius: 15,
            backgroundColor: const Color(0xFFEEF2FF),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Color(0xFF4F46E5),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          title: Text(
            details.modules[index],
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(
            'Guided lessons and activities',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Course syllabus',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          ...moduleTiles,
        ],
      ),
    );
  }
}
