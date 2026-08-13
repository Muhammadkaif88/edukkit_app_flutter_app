import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/course_model.dart';
import '../../models/lesson_model.dart';
import 'data/courses_data.dart';
import 'lesson_player_screen.dart';

/// Redesigned Course Lesson / Playlist Screen.
/// Recreates the exact UI reference design with a full-bleed hero banner,
/// tab navigation, vertical lesson playlist with free preview vs locked badges,
/// duration tags, action icons, three-dot menus, and bottom enrollment CTA.
class CoursePlaylistScreen extends StatefulWidget {
  final CourseModel course;
  final List<LessonModel>? lessons;

  const CoursePlaylistScreen({
    super.key,
    required this.course,
    this.lessons,
  });

  @override
  State<CoursePlaylistScreen> createState() => _CoursePlaylistScreenState();
}

class _CoursePlaylistScreenState extends State<CoursePlaylistScreen> {
  int _selectedTabIndex = 0; // 0: Lessons, 1: Resources
  late List<LessonModel> _lessonsList;

  @override
  void initState() {
    super.initState();
    _lessonsList = widget.lessons ?? CoursesData.getLessonsForCourse(widget.course);
  }

  void _onShareCourse() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.share_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Course link copied for "${widget.course.title}"',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4F46E5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onLessonTap(LessonModel lesson) {
    if (lesson.isLocked) {
      _showLockedDialog(lesson);
    } else {
      _playLesson(lesson);
    }
  }

  void _playLesson(LessonModel lesson) {
    final payload = _lessonsList
        .map((l) => {
              'title': l.title,
              'duration': l.duration,
              'isLocked': l.isLocked,
              'isFreePreview': l.isFreePreview,
            })
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LessonPlayerScreen(
          courseTitle: widget.course.title,
          initialLessonTitle: lesson.title,
          lessons: payload,
        ),
      ),
    );
  }

  void _showLockedDialog(LessonModel lesson) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_rounded,
                color: Color(0xFF4F46E5),
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Lesson ${lesson.number} is Locked',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enroll in "${widget.course.title}" to unlock all ${widget.course.lessonsCount > 0 ? widget.course.lessonsCount : _lessonsList.length} lessons, full projects, hardware kits and resources.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                height: 1.45,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _showEnrollDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Enroll Now to Unlock',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEnrollDialog(BuildContext context) {
    final fee = widget.course.price > 0 ? widget.course.price.toInt() : 499;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Enrolling in ${widget.course.title} for ₹$fee...',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFF4F46E5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void _showLessonMenu(BuildContext context, LessonModel lesson) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              lesson.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            _buildMenuItem(
              icon: Icons.bookmark_border_rounded,
              title: 'Save Lesson',
              onTap: () {
                Navigator.pop(ctx);
                _showToast('Lesson saved to your bookmarks');
              },
            ),
            _buildMenuItem(
              icon: Icons.check_circle_outline_rounded,
              title: 'Mark as Completed',
              onTap: () {
                Navigator.pop(ctx);
                _showToast('Marked lesson as completed!');
              },
            ),
            _buildMenuItem(
              icon: Icons.download_outlined,
              title: 'Download Video Lesson',
              onTap: () {
                Navigator.pop(ctx);
                _showToast('Offline download feature coming soon!');
              },
            ),
            _buildMenuItem(
              icon: Icons.edit_note_rounded,
              title: 'Add Study Notes',
              onTap: () {
                Navigator.pop(ctx);
                _showToast('Study notes workspace opened');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xFF4F46E5), size: 22),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1E293B),
        ),
      ),
      onTap: onTap,
    );
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Color _getLevelColor(String level) {
    final lvl = level.toLowerCase();
    if (lvl.contains('beg')) return const Color(0xFF10B981); // Green
    if (lvl.contains('inter')) return const Color(0xFFF59E0B); // Amber
    return const Color(0xFFEF4444); // Red/Purple for Advanced
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Off-white clean Edukkit background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A),
            size: 18,
          ),
        ),
        title: Text(
          widget.course.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _onShareCourse,
            icon: const Icon(
              Icons.share_outlined,
              color: Color(0xFF4F46E5),
              size: 22,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              // 1. Course Hero Banner
              _buildHeroBanner(context),

              const SizedBox(height: 16),

              // 2. Tab Section (Lessons | Resources)
              _buildTabSection(),

              const SizedBox(height: 16),

              // 3. Tab Content
              if (_selectedTabIndex == 0)
                _buildLessonsPlaylist(context)
              else
                _buildResourcesSection(context),
            ],
          ),
        ),
      ),
    );
  }

  // ── 1. Hero Banner ────────────────────────────────────────────────────────
  Widget _buildHeroBanner(BuildContext context) {
    final hasAsset = widget.course.assetPath != null && widget.course.assetPath!.isNotEmpty;
    final hasNetwork = widget.course.thumbnailUrl.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bannerHeight = (constraints.maxWidth * 0.54).clamp(170.0, 230.0);
          return ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: double.infinity,
              height: bannerHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Full-bleed Banner Image (ONE COMPLETE IMAGE)
                  if (hasAsset)
                    Image.asset(
                      widget.course.assetPath!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _buildFallbackBanner(),
                    )
                  else if (hasNetwork)
                    Image.network(
                      widget.course.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _buildFallbackBanner(),
                    )
                  else
                    _buildFallbackBanner(),

                  // Overlaid Hero CTA Button ("Start Learning ▶")
                  Positioned(
                    right: 14,
                    bottom: 14,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (_lessonsList.isNotEmpty) {
                            _playLesson(_lessonsList.first);
                          }
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 9, 9, 9),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4F46E5), // Edukkit Primary Indigo
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4F46E5).withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Start Learning',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 26,
                                height: 26,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Color(0xFF4F46E5),
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildFallbackBanner() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3730A3), Color(0xFF5B21B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              widget.course.level.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.course.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.course.shortDescription,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. Tab Section ────────────────────────────────────────────────────────
  Widget _buildTabSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTabItem(
                index: 0,
                label: 'Lessons',
                icon: Icons.play_circle_fill_rounded,
              ),
            ),
            Expanded(
              child: _buildTabItem(
                index: 1,
                label: 'Resources',
                icon: Icons.description_outlined,
              ),
            ),
          ],
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),
      ],
    );
  }

  Widget _buildTabItem({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedTabIndex == index;
    final color = isSelected ? const Color(0xFF4F46E5) : const Color(0xFF64748B);

    return InkWell(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          // Underline indicator for selected tab
          Container(
            height: 3,
            width: 84,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. Lessons Playlist Content ──────────────────────────────────────────
  Widget _buildLessonsPlaylist(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Vertical List of Lesson Cards
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _lessonsList.length,
            itemBuilder: (context, index) {
              return _buildLessonCard(context, _lessonsList[index]);
            },
          ),

          const SizedBox(height: 12),

          // Bottom Promotional Free Trial CTA Card
          _buildBottomFreeTrialCard(context),
        ],
      ),
    );
  }

  Widget _buildLessonCard(BuildContext context, LessonModel lesson) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 360;
    final thumbnailWidth = isNarrow ? 84.0 : 96.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _onLessonTap(lesson),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A0F172A),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Lesson Number
                SizedBox(
                  width: isNarrow ? 14 : 18,
                  child: Text(
                    '${lesson.number}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF4F46E5),
                    ),
                  ),
                ),
                SizedBox(width: isNarrow ? 6 : 10),

                // 2. Video Thumbnail (16:9 aspect ratio)
                SizedBox(
                  width: thumbnailWidth,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Base image
                          if (lesson.assetThumbnail != null && lesson.assetThumbnail!.isNotEmpty)
                            Image.asset(
                              lesson.assetThumbnail!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _buildFallbackThumbnail(),
                            )
                          else if (lesson.thumbnailUrl.isNotEmpty)
                            Image.network(
                              lesson.thumbnailUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _buildFallbackThumbnail(),
                            )
                          else
                            _buildFallbackThumbnail(),

                          // Dark overlay for locked items
                          if (lesson.isLocked)
                            Container(color: Colors.black.withValues(alpha: 0.4)),

                          // Center play / lock overlay icon
                          Center(
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: lesson.isLocked
                                    ? Colors.black.withValues(alpha: 0.5)
                                    : Colors.white.withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                lesson.isLocked ? Icons.lock_rounded : Icons.play_arrow_rounded,
                                color: lesson.isLocked ? Colors.white : const Color(0xFF0F172A),
                                size: 14,
                              ),
                            ),
                          ),

                          // Bottom-left badge (FREE PREVIEW / LOCKED)
                          Positioned(
                            left: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: lesson.isFreePreview
                                    ? const Color(0xFF4F46E5) // Indigo for Free Preview
                                    : const Color(0xFF1E293B), // Dark for Locked
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(5),
                                  bottomLeft: Radius.circular(10),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (lesson.isLocked) ...[
                                    const Icon(Icons.lock_rounded, color: Colors.white, size: 7),
                                    const SizedBox(width: 2),
                                  ],
                                  Text(
                                    lesson.isFreePreview ? 'FREE PREVIEW' : 'LOCKED',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: 7.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.2,
                                    ),
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
                const SizedBox(width: 10),

                // 3. Lesson Information (Title + Metadata)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        lesson.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 8,
                        runSpacing: 2,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.ondemand_video_rounded,
                                size: 12,
                                color: Color(0xFF4F46E5),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                lesson.type,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bar_chart_rounded,
                                size: 12,
                                color: _getLevelColor(lesson.level),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                lesson.level,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),

                // 4. Right side (Duration badge + Play/Lock button + 3-dots menu)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Duration Badge Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0EBFF), // Light purple badge
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        lesson.duration,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF4F46E5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Play or Lock Circular Button
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: lesson.isLocked
                            ? const Color(0xFFF1F5F9) // Muted gray
                            : const Color(0xFF4F46E5), // Indigo
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        lesson.isLocked ? Icons.lock_rounded : Icons.play_arrow_rounded,
                        color: lesson.isLocked ? const Color(0xFF94A3B8) : Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 2),

                    // Three Dots Menu
                    InkWell(
                      onTap: () => _showLessonMenu(context, lesson),
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.more_vert_rounded,
                          size: 18,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackThumbnail() {
    return Container(
      color: const Color(0xFFEEF2FF),
      child: const Center(
        child: Icon(
          Icons.play_circle_outline_rounded,
          color: Color(0xFF4F46E5),
          size: 20,
        ),
      ),
    );
  }

  // ── 4. Bottom Promotional Card (Free Trial CTA) ───────────────────────────
  Widget _buildBottomFreeTrialCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F0FF), // Subtle light purple background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2D9FF)),
      ),
      child: Row(
        children: [
          // Gift Box Icon 🎁
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.card_giftcard_rounded,
              color: Color(0xFF4F46E5),
              size: 22,
            ),
          ),
          const SizedBox(width: 10),

          // Promo details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Watch the first 3 lessons for free.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Enroll now to unlock all lessons, projects and resources.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Enroll Now Button
          OutlinedButton(
            onPressed: () => _showEnrollDialog(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF4F46E5), width: 1.2),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Text(
              'Enroll Now',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF4F46E5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 5. Resources Tab Content ─────────────────────────────────────────────
  Widget _buildResourcesSection(BuildContext context) {
    final resourcesList = [
      {
        'title': '${widget.course.title} Student Lab Manual',
        'type': 'PDF Document',
        'size': '12.4 MB',
        'icon': Icons.picture_as_pdf_rounded,
      },
      {
        'title': 'Circuit Schematics & Component Diagrams',
        'type': 'PDF Schematics',
        'size': '4.8 MB',
        'icon': Icons.developer_board_rounded,
      },
      {
        'title': 'Complete Source Code & Project Repository',
        'type': 'ZIP Archive',
        'size': '8.2 MB',
        'icon': Icons.code_rounded,
      },
      {
        'title': '3D Printable Robot Parts (.STL & .STEP)',
        'type': '3D CAD Models',
        'size': '15.6 MB',
        'icon': Icons.view_in_ar_rounded,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Course Resources & Downloads',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Download project files, manuals, schematics and code samples.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: resourcesList.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (ctx, idx) {
              final res = resourcesList[idx];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        res['icon'] as IconData,
                        color: const Color(0xFF4F46E5),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            res['title'] as String,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${res['type']} • ${res['size']}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.download_for_offline_rounded,
                        color: Color(0xFF4F46E5),
                        size: 24,
                      ),
                      onPressed: () => _showToast('Downloading ${res['title']}...'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
