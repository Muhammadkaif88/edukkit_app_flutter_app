import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/security/drm_license_service.dart';
import '../../core/security/drm_types.dart';
import '../../core/security/dynamic_watermark_layer.dart';
import '../../core/security/offline_learning_manager.dart';
import '../../core/security/secure_window_manager.dart';
import '../../models/course_model.dart';
import '../../models/lesson_model.dart';
import 'course_detail_screen.dart';

/// EDUKKIT — PREMIUM VIDEO LESSON PLAYER SCREEN WITH COMMERCIAL-GRADE SECURITY
///
/// Security & Architecture Features:
/// - Android WindowManager.LayoutParams.FLAG_SECURE protection (blocks screenshots, recordings & recents capture).
/// - iOS Screen capture detection (pauses playback and blackouts video surface if AirPlay / recording is active).
/// - Platform DRM & Backend Entitlement Authorization (Widevine / FairPlay).
/// - Dynamic moving anti-leak watermark layer over video surface.
/// - Offline DRM protected learning with KeySetId & private app vault storage.
/// - Single centralized play button rule & full responsive design (320px–412px & tablet/desktop).
class LessonPlayerScreen extends StatefulWidget {
  final String courseTitle;
  final String initialLessonTitle;
  final List<dynamic> lessons; // Accepts List<LessonModel> or List<Map<String, dynamic>>
  final CourseModel? course;

  const LessonPlayerScreen({
    super.key,
    required this.courseTitle,
    required this.initialLessonTitle,
    required this.lessons,
    this.course,
  });

  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends State<LessonPlayerScreen> {
  late List<LessonModel> _unifiedLessons;
  late int _currentLessonIndex;

  bool _isPlaying = false;
  double _progressSeconds = 84.0; // 01:24 elapsed
  double _totalSeconds = 165.0; // 02:45 total
  double _playbackSpeed = 1.0;
  bool _isSaved = false;
  int _activeTabIndex = 0; // 0: Overview, 1: Notes, 2: Circuit Diagram, 3: Resources, 4: Q&A
  final Set<int> _completedLessonIndices = {0, 1, 2}; // First 3 lessons completed by default
  final List<String> _userAddedNotes = [];

  // Security Management
  final SecureWindowManager _secureWindow = SecureWindowManager();
  final DrmLicenseService _drmService = DrmLicenseService();
  final OfflineLearningManager _offlineManager = OfflineLearningManager();
  StreamSubscription<bool>? _captureSubscription;
  bool _isScreenCaptured = false;
  SecurityState _securityState = SecurityState.loading;
  PlaybackEntitlement? _currentEntitlement;
  SecurityState get securityState => _securityState;
  PlaybackEntitlement? get currentEntitlement => _currentEntitlement;

  final List<Map<String, String>> _qnaThreads = [
    {
      'author': 'Rahul Sharma',
      'avatar': 'R',
      'time': '2 hours ago',
      'question': 'How does the L298N motor driver control the DC motor direction?',
      'answer': 'The L298N uses H-Bridge circuits. Changing logic levels on IN1 & IN2 reverses current flow to change motor rotation direction!',
    },
    {
      'author': 'Ananya V.',
      'avatar': 'A',
      'time': '1 day ago',
      'question': 'Can I power the Arduino and motors from the same 18650 battery pack?',
      'answer': 'Yes! You can power the motor driver VIN directly from the battery pack and power Arduino via 5V pin or USB.',
    },
  ];
  final TextEditingController _qnaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _normalizeLessons();
    _initSecurity();
  }

  Future<void> _initSecurity() async {
    _secureWindow.initialize();
    await _secureWindow.enableSecureWindow();
    await _offlineManager.initialize();

    // Listen to iOS screen capture / recording changes
    _captureSubscription = _secureWindow.onScreenCaptureChanged.listen((isCaptured) {
      if (mounted) {
        setState(() {
          _isScreenCaptured = isCaptured;
          if (isCaptured && _isPlaying) {
            _isPlaying = false;
            _securityState = SecurityState.screenCaptureDetected;
          }
        });
      }
    });

    _authorizeCurrentLesson();
  }

  Future<void> _authorizeCurrentLesson() async {
    final lesson = _currentLesson;
    setState(() => _securityState = SecurityState.loading);

    try {
      final entitlement = await _drmService.requestPlaybackAuthorization(
        userId: 'kaif_user_4821',
        courseId: widget.course?.id ?? 'course_robotics_01',
        lessonId: 'lesson_${lesson.number}',
        isFreePreview: lesson.isFreePreview,
      );

      if (mounted) {
        setState(() {
          _currentEntitlement = entitlement;
          if (lesson.isLocked && !entitlement.isAuthorized) {
            _securityState = SecurityState.locked;
          } else if (entitlement.isFreePreview) {
            _securityState = SecurityState.freePreview;
          } else if (entitlement.isAuthorized) {
            _securityState = SecurityState.authorized;
          } else {
            _securityState = SecurityState.licenseError;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _securityState = SecurityState.error);
      }
    }
  }

  void _normalizeLessons() {
    if (widget.lessons.isEmpty) {
      _unifiedLessons = [
        const LessonModel(
          number: 1,
          title: 'Welcome to Junior Robotics Engineer',
          duration: '02:45',
          level: 'Beginner',
          type: 'Video Lesson',
          isFreePreview: true,
          isLocked: false,
          isCompleted: true,
          assetThumbnail: 'assets/images/courses/featured_course_banner_artwork.png',
        )
      ];
    } else {
      _unifiedLessons = widget.lessons.map((item) {
        if (item is LessonModel) {
          return item;
        } else if (item is Map<String, dynamic>) {
          return LessonModel(
            number: (item['number'] as num?)?.toInt() ?? 1,
            title: item['title'] ?? 'Lesson',
            duration: item['duration'] ?? '05:00',
            level: item['level'] ?? 'Beginner',
            type: item['type'] ?? 'Video Lesson',
            isFreePreview: item['isFreePreview'] ?? item['is_free_preview'] ?? false,
            isLocked: item['isLocked'] ?? item['is_locked'] ?? true,
            isCompleted: item['isCompleted'] ?? item['is_completed'] ?? false,
            videoUrl: item['videoUrl'] ?? item['video_url'] ?? '',
            assetThumbnail: item['assetThumbnail'] ?? item['asset_thumbnail'] ?? 'assets/images/courses/electronics_board_3d.png',
          );
        }
        return const LessonModel(
          number: 1,
          title: 'Lesson',
          duration: '05:00',
        );
      }).toList();
    }

    final foundIndex = _unifiedLessons.indexWhere(
      (l) => l.title.toLowerCase().trim() == widget.initialLessonTitle.toLowerCase().trim(),
    );
    _currentLessonIndex = foundIndex != -1 ? foundIndex : 0;
  }

  LessonModel get _currentLesson => _unifiedLessons[_currentLessonIndex];

  void _onSelectLesson(int index) {
    if (index < 0 || index >= _unifiedLessons.length) return;
    final target = _unifiedLessons[index];
    if (target.isLocked && !_isLessonDownloaded(target)) {
      _showEnrollmentPrompt(target);
    } else {
      setState(() {
        _currentLessonIndex = index;
        _isPlaying = false;
        _progressSeconds = 0.0;
        _totalSeconds = _parseDurationToSeconds(target.duration);
      });
      _authorizeCurrentLesson();
    }
  }

  bool _isLessonDownloaded(LessonModel lesson) {
    final courseId = widget.course?.id ?? 'course_robotics_01';
    return _offlineManager.isLessonDownloaded(courseId, lesson.number);
  }

  double _parseDurationToSeconds(String durationStr) {
    try {
      final parts = durationStr.split(':');
      if (parts.length == 2) {
        return (int.parse(parts[0]) * 60 + int.parse(parts[1])).toDouble();
      }
    } catch (_) {}
    return 165.0;
  }

  String _formatSeconds(double sec) {
    final total = sec.toInt();
    final minutes = (total ~/ 60).toString().padLeft(2, '0');
    final seconds = (total % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _togglePlayPause() {
    if (_isScreenCaptured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Screen recording is disabled for protected course lessons.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    if (_currentLesson.isLocked && !_isLessonDownloaded(_currentLesson)) {
      _showEnrollmentPrompt(_currentLesson);
      return;
    }

    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying && !_completedLessonIndices.contains(_currentLessonIndex)) {
        _completedLessonIndices.add(_currentLessonIndex);
      }
    });
  }

  void _cyclePlaybackSpeed() {
    setState(() {
      if (_playbackSpeed == 1.0) {
        _playbackSpeed = 1.25;
      } else if (_playbackSpeed == 1.25) {
        _playbackSpeed = 1.5;
      } else if (_playbackSpeed == 1.5) {
        _playbackSpeed = 2.0;
      } else if (_playbackSpeed == 2.0) {
        _playbackSpeed = 0.75;
      } else {
        _playbackSpeed = 1.0;
      }
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playback speed: ${_playbackSpeed}x'),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF4F46E5),
      ),
    );
  }

  void _startOfflineDownload(LessonModel lesson) async {
    final courseId = widget.course?.id ?? 'course_robotics_01';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text('Acquiring DRM License & Downloading for offline...')),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF4F46E5),
      ),
    );

    final success = await _offlineManager.downloadLessonForOffline(
      userId: 'kaif_user_4821',
      courseId: courseId,
      courseTitle: widget.courseTitle,
      lesson: lesson,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Lesson securely downloaded with DRM offline license!'),
            backgroundColor: Color(0xFF16A34A),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to secure offline license. Please check your connection.'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  void _showEnrollmentPrompt(LessonModel lesson) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFEEF2FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFF4F46E5),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Locked Lesson 🔒',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Continue learning with the full course "${widget.courseTitle}". Unlock all 24 interactive video lessons, hands-on project guides, circuit schematics & hardware kit!',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  if (widget.course != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CourseDetailScreen(course: widget.course!),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opening course enrollment details...'),
                        backgroundColor: Color(0xFF4F46E5),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Unlock Full Course →',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreMenu() {
    final lesson = _currentLesson;
    final isDownloaded = _isLessonDownloaded(lesson);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.bookmark_outline_rounded, color: Color(0xFF4F46E5)),
              title: Text(_isSaved ? 'Remove from Saved' : 'Save Lesson', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _isSaved = !_isSaved);
              },
            ),
            ListTile(
              leading: Icon(
                isDownloaded ? Icons.offline_pin_rounded : Icons.download_for_offline_outlined,
                color: const Color(0xFF4F46E5),
              ),
              title: Text(
                isDownloaded ? 'Downloaded (Available Offline)' : 'Download for Offline Learning',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Encrypted DRM storage with 30-day offline license',
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF64748B)),
              ),
              onTap: () {
                Navigator.pop(ctx);
                if (!isDownloaded) {
                  _startOfflineDownload(lesson);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined, color: Color(0xFF4F46E5)),
              title: Text('Download Notes & Circuit Diagram', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Downloading study materials...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_problem_outlined, color: Color(0xFFEF4444)),
              title: Text('Report Video Issue', style: GoogleFonts.plusJakartaSans(color: const Color(0xFFEF4444), fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thank you for reporting. Our team will review.')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddNoteDialog() {
    final noteTextController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Add Personal Note 📝',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        content: TextField(
          controller: noteTextController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Type your study note or reminder for this lesson...',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              final text = noteTextController.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  _userAddedNotes.add(text);
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Note added successfully!'),
                    backgroundColor: Color(0xFF4F46E5),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Save Note', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _submitQuestion() {
    final q = _qnaController.text.trim();
    if (q.isEmpty) return;

    setState(() {
      _qnaThreads.insert(0, {
        'author': 'You (Student)',
        'avatar': 'Y',
        'time': 'Just now',
        'question': q,
        'answer': 'Your question has been submitted to the Edukkit Mentor Team. Expect an answer shortly!',
      });
      _qnaController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Question posted to Q&A discussion!'),
        backgroundColor: Color(0xFF4F46E5),
      ),
    );
  }

  @override
  void dispose() {
    _captureSubscription?.cancel();
    _secureWindow.disableSecureWindow();
    _qnaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 800;

            if (isDesktop) {
              // ── DESKTOP / TABLET TWO-COLUMN LAYOUT ───────────────────
              return Column(
                children: [
                  _buildTopHeader(),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Video + Lesson Info + Tabs Content + Prev/Next Navigation
                        Expanded(
                          flex: 3,
                          child: ListView(
                            padding: const EdgeInsets.all(20),
                            children: [
                              _buildVideoPlayerCard(),
                              const SizedBox(height: 16),
                              _buildLessonInformation(),
                              const SizedBox(height: 20),
                              _buildContentTabsSystem(),
                              const SizedBox(height: 16),
                              _buildSelectedTabContent(),
                              const SizedBox(height: 24),
                              _buildPrevNextNavigationButtons(),
                            ],
                          ),
                        ),

                        // Right Column: Next Videos Playlist + Help Card
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                left: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                              ),
                            ),
                            child: ListView(
                              padding: const EdgeInsets.all(20),
                              children: [
                                _buildNextVideosPlaylistSection(),
                                const SizedBox(height: 20),
                                _buildNeedHelpCard(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              // ── MOBILE SINGLE-COLUMN LAYOUT ─────────────────────────
              return Column(
                children: [
                  _buildTopHeader(),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 24),
                      children: [
                        // 1. VIDEO PLAYER
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: _buildVideoPlayerCard(),
                        ),

                        const SizedBox(height: 14),

                        // 2. LESSON INFORMATION
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildLessonInformation(),
                        ),

                        const SizedBox(height: 18),

                        // 3. CONTENT TABS BAR
                        _buildContentTabsSystem(),

                        const SizedBox(height: 16),

                        // 4. SELECTED TAB CONTENT
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildSelectedTabContent(),
                        ),

                        const SizedBox(height: 24),

                        // 5. NEXT VIDEOS / LESSON PLAYLIST
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildNextVideosPlaylistSection(),
                        ),

                        const SizedBox(height: 16),

                        // 6. NEED HELP CARD
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildNeedHelpCard(),
                        ),

                        const SizedBox(height: 24),

                        // 7. PREVIOUS / NEXT LESSON BUTTONS
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildPrevNextNavigationButtons(),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  // ── 1. TOP HEADER WIDGET ──────────────────────────────────────────────
  Widget _buildTopHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Back Button
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 19),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 4),

          // Course & Lesson Titles
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.courseTitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  _currentLesson.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4F46E5),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 4),

          // Right Actions: Save & More (⋯)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Save / Bookmark button
              InkWell(
                onTap: () {
                  setState(() => _isSaved = !_isSaved);
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isSaved ? 'Saved to bookmarks!' : 'Removed from bookmarks'),
                      duration: const Duration(seconds: 1),
                      backgroundColor: const Color(0xFF4F46E5),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: _isSaved ? const Color(0xFF4F46E5) : const Color(0xFF475569),
                        size: 20,
                      ),
                      Text(
                        'Save',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _isSaved ? const Color(0xFF4F46E5) : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 6),

              // More button (⋯)
              InkWell(
                onTap: _showMoreMenu,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.more_horiz_rounded,
                        color: Color(0xFF475569),
                        size: 20,
                      ),
                      Text(
                        'More',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 2. VIDEO PLAYER CARD WIDGET ───────────────────────────────────────
  Widget _buildVideoPlayerCard() {
    final lesson = _currentLesson;
    final isLocked = lesson.isLocked && !_isLessonDownloaded(lesson);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Thumbnail background image
              Image.asset(
                lesson.assetThumbnail != null && lesson.assetThumbnail!.isNotEmpty
                    ? lesson.assetThumbnail!
                    : 'assets/images/courses/featured_course_banner_artwork.png',
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Image.asset(
                  'assets/images/courses/junior_automation.png',
                  fit: BoxFit.cover,
                ),
              ),

              // 2. Dark overlay gradient for video legibility
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.45),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),

              // 3. Dynamic Watermarking Layer (Anti-Leak Deterrent)
              const DynamicWatermarkLayer(
                userIdentifier: 'Kaif',
                deviceIdSuffix: 'EDU-4821',
              ),

              // 4. Top Badges & Control Icons
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Badge: FREE PREVIEW / LOCKED / OFFLINE
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _isLessonDownloaded(lesson)
                            ? const Color(0xFF10B981)
                            : (isLocked ? const Color(0xFF1E293B) : const Color(0xFF4F46E5)),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isLessonDownloaded(lesson)) ...[
                            const Icon(Icons.offline_pin_rounded, size: 11, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              'OFFLINE DRM',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ] else if (isLocked) ...[
                            const Icon(Icons.lock_rounded, size: 11, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              'LOCKED',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ] else ...[
                            Text(
                              'FREE PREVIEW',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Player Top Settings & Fullscreen Icons
                    Row(
                      children: [
                        _buildPlayerIconButton(
                          icon: Icons.settings_outlined,
                          onTap: () {
                            final scheme = _currentEntitlement?.drmScheme.name.toUpperCase() ?? 'WIDEVINE';
                            final stateName = _securityState.name;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Security: $scheme Protected • Status: $stateName (1080p)'),
                                duration: const Duration(seconds: 2),
                                backgroundColor: const Color(0xFF4F46E5),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildPlayerIconButton(
                          icon: Icons.fullscreen_rounded,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Toggled fullscreen video player'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 5. Screen Capture Blackout Overlay (iOS Recording / AirPlay protection)
              if (_isScreenCaptured)
                Container(
                  color: Colors.black,
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.screen_lock_portrait_rounded, color: Color(0xFFEF4444), size: 40),
                        const SizedBox(height: 12),
                        Text(
                          'Protected Content',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Screen recording is disabled for protected course content.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                // 6. Center Play/Pause or Lock Prompt
                Center(
                  child: isLocked
                      ? InkWell(
                          onTap: () => _showEnrollmentPrompt(lesson),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white30),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 36),
                                const SizedBox(height: 6),
                                Text(
                                  'Locked Lesson',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Tap to unlock course',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : InkWell(
                          onTap: _togglePlayPause,
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 2),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Icon(
                              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                ),

              // 7. Bottom Video Controls Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Red Progress Slider
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                        activeTrackColor: const Color(0xFFEF4444),
                        inactiveTrackColor: Colors.white30,
                        thumbColor: const Color(0xFFEF4444),
                        overlayColor: const Color(0x44EF4444),
                      ),
                      child: Slider(
                        value: _progressSeconds.clamp(0.0, _totalSeconds),
                        max: _totalSeconds,
                        onChanged: isLocked
                            ? null
                            : (val) {
                                setState(() => _progressSeconds = val);
                              },
                      ),
                    ),

                    // Controls Row
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      child: Row(
                        children: [
                          // Play/Pause button
                          InkWell(
                            onTap: _togglePlayPause,
                            child: Icon(
                              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Skip Next button
                          InkWell(
                            onTap: () {
                              if (_currentLessonIndex < _unifiedLessons.length - 1) {
                                _onSelectLesson(_currentLessonIndex + 1);
                              }
                            },
                            child: const Icon(
                              Icons.skip_next_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Volume button
                          InkWell(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Volume set to 100%'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            child: const Icon(
                              Icons.volume_up_rounded,
                              color: Colors.white,
                              size: 19,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Timestamp text (e.g. 01:24 / 02:45)
                          Text(
                            '${_formatSeconds(_progressSeconds)} / ${_formatSeconds(_totalSeconds)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),

                          const Spacer(),

                          // Playback Speed pill (1.0x)
                          InkWell(
                            onTap: _cyclePlaybackSpeed,
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${_playbackSpeed}x',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Captions CC icon
                          InkWell(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Captions enabled (English)'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            child: const Icon(
                              Icons.closed_caption_outlined,
                              color: Colors.white,
                              size: 19,
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Fullscreen toggle button
                          InkWell(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Fullscreen Mode'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            child: const Icon(
                              Icons.fullscreen_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerIconButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 16),
        padding: EdgeInsets.zero,
        onPressed: onTap,
      ),
    );
  }

  // ── 3. LESSON INFORMATION WIDGET ──────────────────────────────────────
  Widget _buildLessonInformation() {
    final lesson = _currentLesson;
    final isCompleted = _completedLessonIndices.contains(_currentLessonIndex);
    final isDownloaded = _isLessonDownloaded(lesson);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                lesson.title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.3,
                  height: 1.25,
                ),
              ),
            ),
            if (isCompleted) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Completed',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),

        // Metadata Pills Row
        Row(
          children: [
            _buildMetaBadge(lesson.type.isNotEmpty ? lesson.type : 'Video Lesson', const Color(0xFFEEF2FF), const Color(0xFF4F46E5)),
            const SizedBox(width: 8),
            _buildMetaBadge(lesson.level.isNotEmpty ? lesson.level : 'Beginner', const Color(0xFFF1F5F9), const Color(0xFF475569)),
            const SizedBox(width: 8),
            _buildMetaBadge(lesson.duration, const Color(0xFFF1F5F9), const Color(0xFF475569)),
            if (isDownloaded) ...[
              const SizedBox(width: 8),
              _buildMetaBadge('Offline DRM Ready', const Color(0xFFDCFCE7), const Color(0xFF15803D)),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildMetaBadge(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }

  // ── 4. CONTENT TABS SYSTEM WIDGET ─────────────────────────────────────
  Widget _buildContentTabsSystem() {
    final tabs = [
      {'id': 0, 'label': 'Overview', 'icon': Icons.menu_book_rounded},
      {'id': 1, 'label': 'Notes', 'icon': Icons.description_outlined},
      {'id': 2, 'label': 'Circuit Diagram', 'icon': Icons.alt_route_rounded},
      {'id': 3, 'label': 'Resources', 'icon': Icons.folder_open_rounded},
      {'id': 4, 'label': 'Q&A', 'icon': Icons.chat_bubble_outline_rounded},
    ];

    return Container(
      height: 44,
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: tabs.map((tab) {
            final id = tab['id'] as int;
            final isSelected = _activeTabIndex == id;
            return Padding(
              padding: const EdgeInsets.only(right: 20),
              child: InkWell(
                onTap: () => setState(() => _activeTabIndex = id),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tab['icon'] as IconData,
                        size: 16,
                        color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tab['label'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── 5. SELECTED TAB CONTENT SWITCHER ──────────────────────────────────
  Widget _buildSelectedTabContent() {
    switch (_activeTabIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildNotesTab();
      case 2:
        return _buildCircuitDiagramTab();
      case 3:
        return _buildResourcesTab();
      case 4:
        return _buildQnaTab();
      default:
        return _buildOverviewTab();
    }
  }

  // ── 6. OVERVIEW TAB VIEW ──────────────────────────────────────────────
  Widget _buildOverviewTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What You\'ll Learn',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              _buildOverviewCheckItem('Introduction to the course and what we will build'),
              _buildOverviewCheckItem('Understanding the components used in robotics'),
              _buildOverviewCheckItem('How our robot kit & microcontrollers work'),
              _buildOverviewCheckItem('Safety tips and best practices for electronics'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About This Lesson',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'In this introductory lesson, we outline the fundamental concepts of robotics, hardware assembly, motor driver interfacing, and circuit safety. You will follow hands-on step-by-step instructions designed specifically for beginners.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Color(0xFFEEF2FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, size: 12, color: Color(0xFF4F46E5)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 7. NOTES TAB VIEW ─────────────────────────────────────────────────
  Widget _buildNotesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lesson Notes',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Downloading Lesson Notes PDF...'),
                    backgroundColor: Color(0xFF4F46E5),
                  ),
                );
              },
              icon: const Icon(Icons.download_rounded, size: 15, color: Color(0xFF4F46E5)),
              label: Text(
                'Download PDF',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4F46E5),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Key Points Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.assignment_turned_in_rounded, size: 16, color: Color(0xFF4F46E5)),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Key Points',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildBulletPoint('Robotics combines electronics, mechanics and programming into interactive builds.'),
              _buildBulletPoint('This course is designed specifically for absolute beginners.'),
              _buildBulletPoint('You will learn by doing practical projects with real hardware components.'),
              _buildBulletPoint('Always verify power connections before switching on battery power.'),
            ],
          ),
        ),

        // User Added Personal Notes
        if (_userAddedNotes.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Personal Study Notes 📝',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 8),
                ..._userAddedNotes.map(
                  (note) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• $note',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF78350F),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 12),

        // Add Note Button
        OutlinedButton.icon(
          onPressed: _showAddNoteDialog,
          icon: const Icon(Icons.add_rounded, size: 16, color: Color(0xFF4F46E5)),
          label: Text(
            'Add Note',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF4F46E5),
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFC7D2FE)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w900, color: const Color(0xFF4F46E5))),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF334155),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 8. CIRCUIT DIAGRAM TAB VIEW ───────────────────────────────────────
  Widget _buildCircuitDiagramTab() {
    final lesson = _currentLesson;
    final hasDiagram = lesson.circuitDiagramAsset != null || _currentLessonIndex <= 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Circuit Diagram',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Downloading High-Res Schematic PNG...'),
                        backgroundColor: Color(0xFF4F46E5),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download_rounded, size: 15, color: Color(0xFF4F46E5)),
                  label: Text('Download', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF4F46E5))),
                ),
                TextButton.icon(
                  onPressed: () => _showCircuitZoomDialog(),
                  icon: const Icon(Icons.zoom_in_rounded, size: 15, color: Color(0xFF4F46E5)),
                  label: Text('Zoom', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF4F46E5))),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Large Circuit Diagram Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: hasDiagram
              ? Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/courses/electronics_board_3d.png',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (ctx, err, stack) => Image.asset(
                          'assets/images/courses/iot_house_3d.png',
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 13, color: Color(0xFF64748B)),
                          const SizedBox(width: 6),
                          Text(
                            'Pinout: Arduino Uno ➔ L298N Motor Driver ➔ TT Motors',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.schema_outlined, size: 40, color: Color(0xFF94A3B8)),
                        const SizedBox(height: 8),
                        Text(
                          'Circuit diagram will be available for this lesson.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  void _showCircuitZoomDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Circuit Diagram Zoom', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16)),
                  IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 8),
              InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.0,
                child: Image.asset(
                  'assets/images/courses/electronics_board_3d.png',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 9. RESOURCES TAB VIEW ─────────────────────────────────────────────
  Widget _buildResourcesTab() {
    final resources = [
      {'title': 'Junior_Robotics_Lesson_1_Notes.pdf', 'type': 'PDF Notes', 'size': '2.4 MB', 'icon': Icons.picture_as_pdf_rounded, 'color': const Color(0xFFEF4444)},
      {'title': 'L298N_Arduino_Motor_Driver_Schematic.png', 'type': 'Circuit Diagram', 'size': '1.1 MB', 'icon': Icons.image_rounded, 'color': const Color(0xFF3B82F6)},
      {'title': 'Robotics_Motor_Control_Program.ino', 'type': 'Source Code', 'size': '45 KB', 'icon': Icons.code_rounded, 'color': const Color(0xFF10B981)},
      {'title': 'Hardware_Bill_of_Materials.xlsx', 'type': 'Project Files', 'size': '180 KB', 'icon': Icons.table_chart_rounded, 'color': const Color(0xFFF59E0B)},
      {'title': 'L298N_Dual_H_Bridge_Datasheet.pdf', 'type': 'Datasheet', 'size': '850 KB', 'icon': Icons.description_rounded, 'color': const Color(0xFF8B5CF6)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lesson Resources',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),
        ...resources.map(
          (res) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (res['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(res['icon'] as IconData, color: res['color'] as Color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        res['title'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${res['type']} • ${res['size']}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.download_rounded, color: Color(0xFF4F46E5), size: 20),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Downloading ${res['title']}...'),
                        backgroundColor: const Color(0xFF4F46E5),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── 10. Q&A TAB VIEW ──────────────────────────────────────────────────
  Widget _buildQnaTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Have a question?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Ask something about this lesson',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 12),

        // Input Field + Ask Button
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _qnaController,
                style: GoogleFonts.plusJakartaSans(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Type your doubt here...',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _submitQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              child: Text(
                'Ask Now',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Discussion Thread List
        ..._qnaThreads.map(
          (thread) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 13,
                      backgroundColor: const Color(0xFFEEF2FF),
                      child: Text(
                        thread['avatar']!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF4F46E5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      thread['author']!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      thread['time']!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Q: ${thread['question']}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.school_rounded, size: 14, color: Color(0xFF4F46E5)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          thread['answer']!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF475569),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── 11. NEXT VIDEOS / LESSON PLAYLIST SECTION ────────────────────────
  Widget _buildNextVideosPlaylistSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Next Videos',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_completedLessonIndices.length} / ${_unifiedLessons.length}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Vertical List of Lessons
        ...List.generate(_unifiedLessons.length, (index) {
          final lesson = _unifiedLessons[index];
          final isSelected = index == _currentLessonIndex;
          final isCompleted = _completedLessonIndices.contains(index);
          final isDownloaded = _isLessonDownloaded(lesson);

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? const Color(0xFFC7D2FE) : const Color(0xFFE2E8F0),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: InkWell(
              onTap: () => _onSelectLesson(index),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    // Lesson Index Number
                    SizedBox(
                      width: 20,
                      child: Text(
                        '${lesson.number}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Thumbnail with Small Play Overlay / Lock
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            lesson.assetThumbnail != null && lesson.assetThumbnail!.isNotEmpty
                                ? lesson.assetThumbnail!
                                : 'assets/images/courses/electronics_board_3d.png',
                            width: 64,
                            height: 44,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Container(
                              width: 64,
                              height: 44,
                              color: const Color(0xFFE2E8F0),
                              child: const Icon(Icons.play_circle_outline, size: 20, color: Color(0xFF64748B)),
                            ),
                          ),
                        ),
                        Container(
                          width: 64,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        // Small play icon overlay or lock
                        Icon(
                          isDownloaded
                              ? Icons.offline_pin_rounded
                              : (lesson.isLocked ? Icons.lock_rounded : Icons.play_arrow_rounded),
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),

                    const SizedBox(width: 12),

                    // Lesson Title & Meta
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lesson.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                              color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF0F172A),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isDownloaded
                                      ? const Color(0xFFDCFCE7)
                                      : (lesson.isLocked ? const Color(0xFFF1F5F9) : const Color(0xFFEEF2FF)),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isDownloaded
                                      ? 'OFFLINE'
                                      : (lesson.isLocked ? 'LOCKED' : 'FREE PREVIEW'),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                    color: isDownloaded
                                        ? const Color(0xFF15803D)
                                        : (lesson.isLocked ? const Color(0xFF64748B) : const Color(0xFF4F46E5)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                lesson.duration,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Completed Indicator Checkmark
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Color(0xFFDCFCE7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF16A34A),
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 8),

        // View All Lessons Button
        InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Showing all ${_unifiedLessons.length} lessons'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'View All Lessons →',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4F46E5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── 12. NEED HELP CARD WIDGET ─────────────────────────────────────────
  Widget _buildNeedHelpCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need Help? 🤔',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stuck on something? Ask your doubt in Q&A section!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () => setState(() => _activeTabIndex = 4),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Ask Now',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Image.asset(
            'assets/images/courses/robot_featured_3d.png',
            width: 70,
            height: 70,
            fit: BoxFit.contain,
            errorBuilder: (ctx, err, stack) => const Icon(Icons.support_agent_rounded, size: 48, color: Color(0xFF4F46E5)),
          ),
        ],
      ),
    );
  }

  // ── 13. PREVIOUS / NEXT LESSON NAVIGATION BUTTONS ────────────────────
  Widget _buildPrevNextNavigationButtons() {
    final hasPrev = _currentLessonIndex > 0;
    final hasNext = _currentLessonIndex < _unifiedLessons.length - 1;

    return Row(
      children: [
        // Previous Lesson Button
        Expanded(
          child: SizedBox(
            height: 46,
            child: OutlinedButton(
              onPressed: hasPrev
                  ? () {
                      _onSelectLesson(_currentLessonIndex - 1);
                    }
                  : null,
              style: OutlinedButton.styleFrom(
                backgroundColor: hasPrev ? const Color(0xFFEEF2FF) : const Color(0xFFF1F5F9),
                side: BorderSide(
                  color: hasPrev ? const Color(0xFFC7D2FE) : const Color(0xFFE2E8F0),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_back_rounded,
                    size: 16,
                    color: hasPrev ? const Color(0xFF4F46E5) : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Previous Lesson',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: hasPrev ? const Color(0xFF4F46E5) : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Next Lesson Button
        Expanded(
          child: SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: hasNext
                  ? () {
                      _onSelectLesson(_currentLessonIndex + 1);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: hasNext ? const Color(0xFF4F46E5) : const Color(0xFF94A3B8),
                elevation: hasNext ? 2 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Next Lesson',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
