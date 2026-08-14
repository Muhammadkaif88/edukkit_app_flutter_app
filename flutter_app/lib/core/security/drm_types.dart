/// Supported Digital Rights Management Schemes
enum DrmScheme {
  widevine, // Android Media3 / ExoPlayer
  fairplay, // iOS AVFoundation
  clearKey, // Sandbox / Testing (Debug Only)
  none,     // Free Unprotected Content
}

/// Comprehensive Player & Playback Security States
enum SecurityState {
  loading,
  authorized,
  playing,
  paused,
  freePreview,
  locked,
  licenseError,
  tokenExpired,
  offlineAvailable,
  offlineExpired,
  accessRevoked,
  deviceNotAuthorized,
  screenCaptureDetected,
  networkRequired,
  error,
}

/// Course Entitlement Status
enum EntitlementStatus {
  active,
  expired,
  revoked,
  unpurchased,
  deviceLimitExceeded,
}

/// Security Audit Events
enum SecurityEventType {
  playbackAuthorized,
  playbackDenied,
  licenseRequested,
  licenseAcquired,
  licenseFailed,
  offlineDownloadStarted,
  offlineDownloadCompleted,
  offlineLicenseExpired,
  offlineLicenseRenewed,
  offlineAccessRevoked,
  screenCaptureDetected,
  screenCaptureStopped,
  screenshotAttemptDetected,
  deviceAuthorized,
  deviceRejected,
  accessRevoked,
}

/// Model for Short-Lived Playback Authorization
class PlaybackEntitlement {
  final String userId;
  final String courseId;
  final String lessonId;
  final bool isAuthorized;
  final bool isFreePreview;
  final String? playbackToken;
  final DateTime? tokenExpiresAt;
  final String? streamManifestUrl;
  final String? licenseServerUrl;
  final Map<String, String> licenseHeaders;
  final DrmScheme drmScheme;
  final String? certificateUrl; // For iOS FairPlay Application Certificate
  final int maxOfflineDays;
  final String? rejectionReason;

  const PlaybackEntitlement({
    required this.userId,
    required this.courseId,
    required this.lessonId,
    required this.isAuthorized,
    this.isFreePreview = false,
    this.playbackToken,
    this.tokenExpiresAt,
    this.streamManifestUrl,
    this.licenseServerUrl,
    this.licenseHeaders = const {},
    this.drmScheme = DrmScheme.none,
    this.certificateUrl,
    this.maxOfflineDays = 30,
    this.rejectionReason,
  });

  bool get isTokenValid {
    if (isFreePreview) return true;
    if (!isAuthorized || playbackToken == null) return false;
    if (tokenExpiresAt == null) return true;
    return DateTime.now().isBefore(tokenExpiresAt!);
  }

  factory PlaybackEntitlement.fromJson(Map<String, dynamic> json) {
    DrmScheme scheme = DrmScheme.none;
    final schemeStr = json['drm_scheme']?.toString().toLowerCase();
    if (schemeStr == 'widevine') scheme = DrmScheme.widevine;
    if (schemeStr == 'fairplay') scheme = DrmScheme.fairplay;
    if (schemeStr == 'clearkey') scheme = DrmScheme.clearKey;

    return PlaybackEntitlement(
      userId: json['user_id'] ?? '',
      courseId: json['course_id'] ?? '',
      lessonId: json['lesson_id'] ?? '',
      isAuthorized: json['is_authorized'] ?? false,
      isFreePreview: json['is_free_preview'] ?? false,
      playbackToken: json['playback_token'],
      tokenExpiresAt: json['token_expires_at'] != null
          ? DateTime.tryParse(json['token_expires_at'])
          : null,
      streamManifestUrl: json['stream_manifest_url'],
      licenseServerUrl: json['license_server_url'],
      licenseHeaders: Map<String, String>.from(json['license_headers'] ?? {}),
      drmScheme: scheme,
      certificateUrl: json['certificate_url'],
      maxOfflineDays: json['max_offline_days'] ?? 30,
      rejectionReason: json['rejection_reason'],
    );
  }
}

/// Model for Storing DRM Protected Offline License Metadata
class OfflineDrmLicense {
  final String licenseId;
  final String courseId;
  final String lessonId;
  final String userId;
  final String keySetId; // Media3 Widevine offline KeySetId or iOS Persistable Content Key reference
  final DateTime downloadedAt;
  final DateTime expiresAt;
  final String localEncryptedMediaPath;
  final int fileSizeBytes;
  final bool isRevoked;

  const OfflineDrmLicense({
    required this.licenseId,
    required this.courseId,
    required this.lessonId,
    required this.userId,
    required this.keySetId,
    required this.downloadedAt,
    required this.expiresAt,
    required this.localEncryptedMediaPath,
    this.fileSizeBytes = 0,
    this.isRevoked = false,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isValid => !isExpired && !isRevoked;

  int get remainingDays {
    final diff = expiresAt.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  factory OfflineDrmLicense.fromJson(Map<String, dynamic> json) {
    return OfflineDrmLicense(
      licenseId: json['license_id'] ?? '',
      courseId: json['course_id'] ?? '',
      lessonId: json['lesson_id'] ?? '',
      userId: json['user_id'] ?? '',
      keySetId: json['key_set_id'] ?? '',
      downloadedAt: DateTime.tryParse(json['downloaded_at'] ?? '') ?? DateTime.now(),
      expiresAt: DateTime.tryParse(json['expires_at'] ?? '') ?? DateTime.now().add(const Duration(days: 30)),
      localEncryptedMediaPath: json['local_encrypted_media_path'] ?? '',
      fileSizeBytes: json['file_size_bytes'] ?? 0,
      isRevoked: json['is_revoked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'license_id': licenseId,
      'course_id': courseId,
      'lesson_id': lessonId,
      'user_id': userId,
      'key_set_id': keySetId,
      'downloaded_at': downloadedAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'local_encrypted_media_path': localEncryptedMediaPath,
      'file_size_bytes': fileSizeBytes,
      'is_revoked': isRevoked,
    };
  }
}

/// Model for Authorized Devices (Device Authorization Limit)
class AuthorizedDevice {
  final String deviceId;
  final String userId;
  final String platform;
  final String deviceName;
  final DateTime lastSeenAt;
  final bool isAuthorized;

  const AuthorizedDevice({
    required this.deviceId,
    required this.userId,
    required this.platform,
    required this.deviceName,
    required this.lastSeenAt,
    this.isAuthorized = true,
  });
}

/// Security Audit Log Record
class SecurityLogEvent {
  final SecurityEventType eventType;
  final String userId;
  final String courseId;
  final String? lessonId;
  final String? deviceId;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const SecurityLogEvent({
    required this.eventType,
    required this.userId,
    required this.courseId,
    this.lessonId,
    this.deviceId,
    required this.timestamp,
    this.metadata = const {},
  });
}
