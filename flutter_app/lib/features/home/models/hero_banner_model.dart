import 'package:flutter/widgets.dart';

/// Supported Banner Navigation Actions for Edukkit Admin Panel
enum BannerClickAction {
  openCourse,
  openCategory,
  openProduct,
  openStore,
  openExternalUrl,
  openYouTube,
  openPdf,
  openWebView,
  openCustomScreen,
  doNothing;

  static BannerClickAction fromString(String? value) {
    if (value == null || value.trim().isEmpty) return BannerClickAction.doNothing;
    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'opencourse':
      case 'open_course':
      case 'course':
        return BannerClickAction.openCourse;
      case 'opencategory':
      case 'open_category':
      case 'category':
        return BannerClickAction.openCategory;
      case 'openproduct':
      case 'open_product':
      case 'product':
        return BannerClickAction.openProduct;
      case 'openstore':
      case 'open_store':
      case 'store':
        return BannerClickAction.openStore;
      case 'openexternalurl':
      case 'open_external_url':
      case 'url':
      case 'external_url':
        return BannerClickAction.openExternalUrl;
      case 'openyoutube':
      case 'open_youtube':
      case 'youtube':
        return BannerClickAction.openYouTube;
      case 'openpdf':
      case 'open_pdf':
      case 'pdf':
        return BannerClickAction.openPdf;
      case 'openwebview':
      case 'open_webview':
      case 'webview':
        return BannerClickAction.openWebView;
      case 'opencustomscreen':
      case 'open_custom_screen':
      case 'custom_screen':
      case 'screen':
        return BannerClickAction.openCustomScreen;
      default:
        return BannerClickAction.doNothing;
    }
  }

  String toMapValue() {
    switch (this) {
      case BannerClickAction.openCourse:
        return 'openCourse';
      case BannerClickAction.openCategory:
        return 'openCategory';
      case BannerClickAction.openProduct:
        return 'openProduct';
      case BannerClickAction.openStore:
        return 'openStore';
      case BannerClickAction.openExternalUrl:
        return 'openExternalUrl';
      case BannerClickAction.openYouTube:
        return 'openYouTube';
      case BannerClickAction.openPdf:
        return 'openPdf';
      case BannerClickAction.openWebView:
        return 'openWebView';
      case BannerClickAction.openCustomScreen:
        return 'openCustomScreen';
      case BannerClickAction.doNothing:
        return 'doNothing';
    }
  }
}

/// Data Model for Edukkit Hero Banners
/// Production-Ready, 100% Admin Panel Compatible Architecture.
class HeroBannerModel {
  final String id;
  final String imagePath;
  final String? title;
  final String? subtitle;
  final String? buttonText;
  final String? badge;
  final AlignmentGeometry? imageAlignment;
  final BannerClickAction clickAction;
  final String? targetValue;
  final bool isActive;
  final int displayOrder;
  final int priority;
  final int autoSlideDurationSeconds;
  final DateTime? startDate;
  final DateTime? endDate;

  const HeroBannerModel({
    required this.id,
    required this.imagePath,
    this.title,
    this.subtitle,
    this.buttonText,
    this.badge,
    this.imageAlignment,
    this.clickAction = BannerClickAction.doNothing,
    this.targetValue,
    this.isActive = true,
    this.displayOrder = 0,
    this.priority = 0,
    this.autoSlideDurationSeconds = 5,
    this.startDate,
    this.endDate,
  });

  /// Optional Field Helper Getters
  bool get hasTitle => title != null && title!.trim().isNotEmpty;
  bool get hasSubtitle => subtitle != null && subtitle!.trim().isNotEmpty;
  bool get hasButtonText => buttonText != null && buttonText!.trim().isNotEmpty;
  bool get hasBadge => badge != null && badge!.trim().isNotEmpty;
  bool get hasTextContent => hasTitle || hasSubtitle || hasButtonText || hasBadge;

  /// Active Schedule Validation Logic
  bool get isScheduledActive {
    if (!isActive) return false;
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  /// Factory to convert JSON/Map payload from Admin API/Firebase
  factory HeroBannerModel.fromMap(Map<String, dynamic> map) {
    return HeroBannerModel(
      id: map['id']?.toString() ?? '',
      imagePath: map['imagePath']?.toString() ?? map['image']?.toString() ?? '',
      title: map['title']?.toString(),
      subtitle: map['subtitle']?.toString(),
      buttonText: map['buttonText']?.toString() ?? map['ctaText']?.toString(),
      badge: map['badge']?.toString(),
      clickAction: BannerClickAction.fromString(map['clickAction']?.toString() ?? map['action']?.toString()),
      targetValue: map['targetValue']?.toString() ?? map['target']?.toString(),
      isActive: map['isActive'] as bool? ?? true,
      displayOrder: (map['displayOrder'] as num?)?.toInt() ?? 0,
      priority: (map['priority'] as num?)?.toInt() ?? 0,
      autoSlideDurationSeconds: (map['autoSlideDurationSeconds'] as num?)?.toInt() ?? 5,
      startDate: map['startDate'] != null ? DateTime.tryParse(map['startDate'].toString()) : null,
      endDate: map['endDate'] != null ? DateTime.tryParse(map['endDate'].toString()) : null,
    );
  }

  /// Converts Model to Map for Admin Panel publishing
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'title': title,
      'subtitle': subtitle,
      'buttonText': buttonText,
      'badge': badge,
      'clickAction': clickAction.toMapValue(),
      'targetValue': targetValue,
      'isActive': isActive,
      'displayOrder': displayOrder,
      'priority': priority,
      'autoSlideDurationSeconds': autoSlideDurationSeconds,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }

  /// CopyWith helper for state mutations
  HeroBannerModel copyWith({
    String? id,
    String? imagePath,
    String? title,
    String? subtitle,
    String? buttonText,
    String? badge,
    AlignmentGeometry? imageAlignment,
    BannerClickAction? clickAction,
    String? targetValue,
    bool? isActive,
    int? displayOrder,
    int? priority,
    int? autoSlideDurationSeconds,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return HeroBannerModel(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      buttonText: buttonText ?? this.buttonText,
      badge: badge ?? this.badge,
      imageAlignment: imageAlignment ?? this.imageAlignment,
      clickAction: clickAction ?? this.clickAction,
      targetValue: targetValue ?? this.targetValue,
      isActive: isActive ?? this.isActive,
      displayOrder: displayOrder ?? this.displayOrder,
      priority: priority ?? this.priority,
      autoSlideDurationSeconds: autoSlideDurationSeconds ?? this.autoSlideDurationSeconds,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  /// Default Banners for Edukkit Home Screen
  static List<HeroBannerModel> get defaultBanners => [
        const HeroBannerModel(
          id: 'banner_1',
          title: 'Build. Create. Innovate.',
          subtitle: 'Hands-on DIY Robotics & Electronics Kits for Curious Minds',
          imagePath: 'assets/images/home/banner_bg_diy_kits.png',
          buttonText: 'Explore Kits Now',
          badge: 'NEW ARRIVAL',
          clickAction: BannerClickAction.openCategory,
          targetValue: 'DIY Kits',
          isActive: true,
          displayOrder: 1,
          autoSlideDurationSeconds: 5,
        ),
        const HeroBannerModel(
          id: 'banner_2',
          title: 'Master Artificial Intelligence',
          subtitle: 'Learn Python, Computer Vision & Neural Networks Step by Step',
          imagePath: 'assets/images/home/banner_bg_diy_kits.png',
          buttonText: 'Start Learning',
          badge: 'POPULAR COURSE',
          clickAction: BannerClickAction.openCourse,
          targetValue: 'ai_course_01',
          isActive: true,
          displayOrder: 2,
          autoSlideDurationSeconds: 5,
        ),
        const HeroBannerModel(
          id: 'banner_3',
          title: 'IoT & Smart Home Automation',
          subtitle: 'Connect ESP32 & Arduino Sensors to Cloud Dashboards',
          imagePath: 'assets/images/home/banner_bg_diy_kits.png',
          buttonText: 'View Projects',
          badge: 'HANDS-ON LAB',
          clickAction: BannerClickAction.openCategory,
          targetValue: 'IoT',
          isActive: true,
          displayOrder: 3,
          autoSlideDurationSeconds: 5,
        ),
      ];
}
