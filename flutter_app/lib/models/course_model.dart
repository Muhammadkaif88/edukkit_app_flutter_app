class CourseModel {
  final String id;
  final String title;
  final String description;
  final String shortDescription;
  final String instructor;
  final double price;
  final String priceText;
  final String thumbnailUrl;
  final String? assetPath;
  final String category;
  final String level;
  final double rating;
  final int lessonsCount;
  final bool isFreePreview;
  final bool isKitIncluded;
  final bool isNew;
  final bool isPopular;
  final String? badgeText;
  final int? badgeColorHex;
  final bool isBookmarked;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    this.shortDescription = '',
    this.instructor = 'Edukkit Team',
    required this.price,
    this.priceText = '',
    required this.thumbnailUrl,
    this.assetPath,
    required this.category,
    this.level = 'Beginner',
    this.rating = 4.8,
    this.lessonsCount = 20,
    this.isFreePreview = false,
    this.isKitIncluded = false,
    this.isNew = false,
    this.isPopular = false,
    this.badgeText,
    this.badgeColorHex,
    this.isBookmarked = false,
  });

  CourseModel copyWith({
    String? id,
    String? title,
    String? description,
    String? shortDescription,
    String? instructor,
    double? price,
    String? priceText,
    String? thumbnailUrl,
    String? assetPath,
    String? category,
    String? level,
    double? rating,
    int? lessonsCount,
    bool? isFreePreview,
    bool? isKitIncluded,
    bool? isNew,
    bool? isPopular,
    String? badgeText,
    int? badgeColorHex,
    bool? isBookmarked,
  }) {
    return CourseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      instructor: instructor ?? this.instructor,
      price: price ?? this.price,
      priceText: priceText ?? this.priceText,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      assetPath: assetPath ?? this.assetPath,
      category: category ?? this.category,
      level: level ?? this.level,
      rating: rating ?? this.rating,
      lessonsCount: lessonsCount ?? this.lessonsCount,
      isFreePreview: isFreePreview ?? this.isFreePreview,
      isKitIncluded: isKitIncluded ?? this.isKitIncluded,
      isNew: isNew ?? this.isNew,
      isPopular: isPopular ?? this.isPopular,
      badgeText: badgeText ?? this.badgeText,
      badgeColorHex: badgeColorHex ?? this.badgeColorHex,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      shortDescription: json['short_description'] ?? json['description'] ?? '',
      instructor: json['instructor'] ?? 'Edukkit Team',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      priceText: json['price_text'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      assetPath: json['asset_path'],
      category: json['category'] ?? 'General',
      level: json['level'] ?? 'Beginner',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      lessonsCount: (json['lessons_count'] as num?)?.toInt() ?? 20,
      isFreePreview: json['is_free_preview'] ?? false,
      isKitIncluded: json['is_kit_included'] ?? false,
      isNew: json['is_new'] ?? false,
      isPopular: json['is_popular'] ?? false,
      badgeText: json['badge_text'],
      badgeColorHex: json['badge_color_hex'],
      isBookmarked: json['is_bookmarked'] ?? false,
    );
  }
}

