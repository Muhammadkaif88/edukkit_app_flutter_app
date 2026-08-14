class LessonModel {
  final int number;
  final String? id;
  final String? courseId;
  final String title;
  final String thumbnailUrl;
  final String? assetThumbnail;
  final String duration;
  final String level;
  final String type;
  final bool isFreePreview;
  final bool isLocked;
  final bool isCompleted;
  final String videoUrl;
  final String? description;
  final List<String>? notes;
  final String? circuitDiagramAsset;
  final List<String> resources;

  const LessonModel({
    required this.number,
    this.id,
    this.courseId,
    required this.title,
    this.thumbnailUrl = '',
    this.assetThumbnail,
    required this.duration,
    this.level = 'Beginner',
    this.type = 'Video Lesson',
    this.isFreePreview = false,
    this.isLocked = true,
    this.isCompleted = false,
    this.videoUrl = '',
    this.description,
    this.notes,
    this.circuitDiagramAsset,
    this.resources = const [],
  });

  LessonModel copyWith({
    int? number,
    String? id,
    String? courseId,
    String? title,
    String? thumbnailUrl,
    String? assetThumbnail,
    String? duration,
    String? level,
    String? type,
    bool? isFreePreview,
    bool? isLocked,
    bool? isCompleted,
    String? videoUrl,
    String? description,
    List<String>? notes,
    String? circuitDiagramAsset,
    List<String>? resources,
  }) {
    return LessonModel(
      number: number ?? this.number,
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      assetThumbnail: assetThumbnail ?? this.assetThumbnail,
      duration: duration ?? this.duration,
      level: level ?? this.level,
      type: type ?? this.type,
      isFreePreview: isFreePreview ?? this.isFreePreview,
      isLocked: isLocked ?? this.isLocked,
      isCompleted: isCompleted ?? this.isCompleted,
      videoUrl: videoUrl ?? this.videoUrl,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      circuitDiagramAsset: circuitDiagramAsset ?? this.circuitDiagramAsset,
      resources: resources ?? this.resources,
    );
  }

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      number: (json['number'] as num?)?.toInt() ?? 1,
      id: json['id'],
      courseId: json['courseId'] ?? json['course_id'],
      title: json['title'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? json['thumbnail'] ?? '',
      assetThumbnail: json['asset_thumbnail'] ?? json['assetThumbnail'],
      duration: json['duration'] ?? '05:00',
      level: json['level'] ?? 'Beginner',
      type: json['type'] ?? 'Video Lesson',
      isFreePreview: json['is_free_preview'] ?? json['isFreePreview'] ?? false,
      isLocked: json['is_locked'] ?? json['isLocked'] ?? true,
      isCompleted: json['is_completed'] ?? json['isCompleted'] ?? false,
      videoUrl: json['video_url'] ?? json['videoUrl'] ?? '',
      description: json['description'],
      notes: json['notes'] != null ? List<String>.from(json['notes']) : null,
      circuitDiagramAsset: json['circuit_diagram_asset'] ?? json['circuitDiagramAsset'],
      resources: List<String>.from(json['resources'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'id': id,
      'course_id': courseId,
      'title': title,
      'thumbnail_url': thumbnailUrl,
      'asset_thumbnail': assetThumbnail,
      'duration': duration,
      'level': level,
      'type': type,
      'is_free_preview': isFreePreview,
      'is_locked': isLocked,
      'is_completed': isCompleted,
      'video_url': videoUrl,
      'description': description,
      'notes': notes,
      'circuit_diagram_asset': circuitDiagramAsset,
      'resources': resources,
    };
  }
}
