import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/lesson_model.dart';
import 'drm_license_service.dart';
import 'drm_types.dart';

/// Record tracking an offline protected lesson
class OfflineLessonItem {
  final String courseId;
  final String courseTitle;
  final LessonModel lesson;
  final OfflineDrmLicense license;
  final int fileSizeBytes;
  final DateTime downloadedAt;

  const OfflineLessonItem({
    required this.courseId,
    required this.courseTitle,
    required this.lesson,
    required this.license,
    required this.fileSizeBytes,
    required this.downloadedAt,
  });

  bool get isExpired => license.isExpired;
  int get remainingDays => license.remainingDays;

  Map<String, dynamic> toJson() {
    return {
      'course_id': courseId,
      'course_title': courseTitle,
      'lesson': lesson.toJson(),
      'license': license.toJson(),
      'file_size_bytes': fileSizeBytes,
      'downloaded_at': downloadedAt.toIso8601String(),
    };
  }

  factory OfflineLessonItem.fromJson(Map<String, dynamic> json) {
    return OfflineLessonItem(
      courseId: json['course_id'] ?? '',
      courseTitle: json['course_title'] ?? 'Course',
      lesson: LessonModel.fromJson(Map<String, dynamic>.from(json['lesson'] ?? {})),
      license: OfflineDrmLicense.fromJson(Map<String, dynamic>.from(json['license'] ?? {})),
      fileSizeBytes: json['file_size_bytes'] ?? 0,
      downloadedAt: DateTime.tryParse(json['downloaded_at'] ?? '') ?? DateTime.now(),
    );
  }
}

/// Offline Learning Manager
/// Manages DRM-protected local media segments, KeySetIds, license renewal,
/// and secure app-private storage.
class OfflineLearningManager extends ChangeNotifier {
  static final OfflineLearningManager _instance = OfflineLearningManager._internal();
  factory OfflineLearningManager() => _instance;
  OfflineLearningManager._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final DrmLicenseService _drmService = DrmLicenseService();

  final Map<String, OfflineLessonItem> _offlineRegistry = {};
  final Map<String, double> _downloadProgress = {}; // Key: lessonId, Value: 0.0 - 1.0

  bool _isInitialized = false;

  Map<String, OfflineLessonItem> get offlineLessons => Map.unmodifiable(_offlineRegistry);
  Map<String, double> get downloadProgress => Map.unmodifiable(_downloadProgress);

  /// Initialize and load offline registry from secure storage
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final dataStr = await _secureStorage.read(key: 'edukkit_offline_registry_v1');
      if (dataStr != null && dataStr.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(dataStr);
        _offlineRegistry.clear();
        for (final item in jsonList) {
          final offlineItem = OfflineLessonItem.fromJson(Map<String, dynamic>.from(item));
          _offlineRegistry['${offlineItem.courseId}-${offlineItem.lesson.number}'] = offlineItem;
        }
      }
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('[OfflineLearning] Error loading registry: $e');
    }
  }

  bool isLessonDownloaded(String courseId, int lessonNumber) {
    final key = '$courseId-$lessonNumber';
    final item = _offlineRegistry[key];
    return item != null && item.license.isValid;
  }

  double? getLessonDownloadProgress(String courseId, int lessonNumber) {
    return _downloadProgress['$courseId-$lessonNumber'];
  }

  /// Start DRM-protected offline download
  Future<bool> downloadLessonForOffline({
    required String userId,
    required String courseId,
    required String courseTitle,
    required LessonModel lesson,
  }) async {
    final key = '$courseId-${lesson.number}';
    if (isLessonDownloaded(courseId, lesson.number)) return true;

    try {
      _downloadProgress[key] = 0.05;
      notifyListeners();

      // 1. Prepare App-Private Encrypted Media Storage Directory
      Directory appDir;
      if (kIsWeb) {
        appDir = Directory.current;
      } else {
        appDir = await getApplicationDocumentsDirectory();
      }
      final secureMediaDir = Directory('${appDir.path}/edukkit_secure_vault/$courseId');
      if (!secureMediaDir.existsSync()) {
        secureMediaDir.createSync(recursive: true);
      }

      final encryptedFilePath = '${secureMediaDir.path}/enc_seg_${lesson.number}.drm';

      // 2. Simulate streaming download with progressive chunk writing
      for (int p = 10; p <= 90; p += 15) {
        await Future.delayed(const Duration(milliseconds: 150));
        _downloadProgress[key] = p / 100.0;
        notifyListeners();
      }

      // Write mock encrypted payload file to private storage
      final file = File(encryptedFilePath);
      await file.writeAsString('EDUKKIT_ENCRYPTED_MEDIA_SEGMENT_V1_${lesson.title}');
      final fileSizeBytes = 24 * 1024 * 1024; // e.g. 24MB

      // 3. Acquire Platform DRM Offline License (Widevine KeySetId / FairPlay Persistable Key)
      final license = await _drmService.acquireOfflineDrmLicense(
        userId: userId,
        courseId: courseId,
        lessonId: 'lesson_${lesson.number}',
        localEncryptedPath: encryptedFilePath,
        fileSizeBytes: fileSizeBytes,
      );

      if (license == null) {
        _downloadProgress.remove(key);
        notifyListeners();
        return false;
      }

      // 4. Save to Offline Registry
      final offlineItem = OfflineLessonItem(
        courseId: courseId,
        courseTitle: courseTitle,
        lesson: lesson,
        license: license,
        fileSizeBytes: fileSizeBytes,
        downloadedAt: DateTime.now(),
      );

      _offlineRegistry[key] = offlineItem;
      _downloadProgress.remove(key);

      await _persistRegistry();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[OfflineLearning] Download error: $e');
      _downloadProgress.remove(key);
      notifyListeners();
      return false;
    }
  }

  /// Remove offline lesson and securely wipe local encrypted media file
  Future<bool> removeOfflineLesson(String courseId, int lessonNumber) async {
    final key = '$courseId-$lessonNumber';
    final item = _offlineRegistry[key];
    if (item == null) return false;

    try {
      final file = File(item.license.localEncryptedMediaPath);
      if (file.existsSync()) {
        file.deleteSync();
      }
      _offlineRegistry.remove(key);
      await _persistRegistry();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[OfflineLearning] Error deleting offline lesson: $e');
      return false;
    }
  }

  /// Calculates total offline storage used in MB/GB
  String getTotalStorageUsedFormatted() {
    int totalBytes = 0;
    for (final item in _offlineRegistry.values) {
      totalBytes += item.fileSizeBytes;
    }
    if (totalBytes < 1024 * 1024) {
      return '${(totalBytes / 1024).toStringAsFixed(1)} KB';
    } else if (totalBytes < 1024 * 1024 * 1024) {
      return '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(totalBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  Future<void> _persistRegistry() async {
    final list = _offlineRegistry.values.map((item) => item.toJson()).toList();
    await _secureStorage.write(
      key: 'edukkit_offline_registry_v1',
      value: jsonEncode(list),
    );
  }
}
