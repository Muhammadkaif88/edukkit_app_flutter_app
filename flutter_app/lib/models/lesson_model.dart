class LessonModel {
  final int number;
  final String title;
  final String thumbnailUrl;
  final String? assetThumbnail;
  final String duration;
  final String level;
  final String type;
  final bool isFreePreview;
  final bool isLocked;
  final String videoUrl;
  final List<String> resources;

  const LessonModel({
    required this.number,
    required this.title,
    this.thumbnailUrl = '',
    this.assetThumbnail,
    required this.duration,
    this.level = 'Beginner',
    this.type = 'Video Lesson',
    this.isFreePreview = false,
    this.isLocked = true,
    this.videoUrl = '',
    this.resources = const [],
  });

  LessonModel copyWith({
    int? number,
    String? title,
    String? thumbnailUrl,
    String? assetThumbnail,
    String? duration,
    String? level,
    String? type,
    bool? isFreePreview,
    bool? isLocked,
    String? videoUrl,
    List<String>? resources,
  }) {
    return LessonModel(
      number: number ?? this.number,
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      assetThumbnail: assetThumbnail ?? this.assetThumbnail,
      duration: duration ?? this.duration,
      level: level ?? this.level,
      type: type ?? this.type,
      isFreePreview: isFreePreview ?? this.isFreePreview,
      isLocked: isLocked ?? this.isLocked,
      videoUrl: videoUrl ?? this.videoUrl,
      resources: resources ?? this.resources,
    );
  }

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      number: (json['number'] as num?)?.toInt() ?? 1,
      title: json['title'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? json['thumbnail'] ?? '',
      assetThumbnail: json['asset_thumbnail'],
      duration: json['duration'] ?? '05:00',
      level: json['level'] ?? 'Beginner',
      type: json['type'] ?? 'Video Lesson',
      isFreePreview: json['is_free_preview'] ?? json['isFreePreview'] ?? false,
      isLocked: json['is_locked'] ?? json['isLocked'] ?? true,
      videoUrl: json['video_url'] ?? json['videoUrl'] ?? '',
      resources: List<String>.from(json['resources'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'title': title,
      'thumbnail_url': thumbnailUrl,
      'asset_thumbnail': assetThumbnail,
      'duration': duration,
      'level': level,
      'type': type,
      'is_free_preview': isFreePreview,
      'is_locked': isLocked,
      'video_url': videoUrl,
      'resources': resources,
    };
  }
}
