import 'course_model.dart';

/// Admin Panel ready data model for Edukkit Featured Courses.
/// Supports future dynamic backend/Admin Panel toggling, ordering, and attributes.
class FeaturedCourseModel {
  final String id;
  final String title;
  final String category;
  final String description;
  final String imageAsset;
  final String level;
  final double rating;
  final int lessonCount;
  final bool kitIncluded;
  final bool isFree;
  final double price;
  final String courseRoute;
  final bool isFeatured;
  final int order;

  const FeaturedCourseModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.imageAsset,
    this.level = 'Beginner',
    this.rating = 4.8,
    this.lessonCount = 24,
    this.kitIncluded = true,
    this.isFree = false,
    this.price = 0.0,
    this.courseRoute = '/course-detail',
    this.isFeatured = true,
    this.order = 1,
  });

  /// Helper method to convert FeaturedCourseModel to standard CourseModel
  /// for navigating seamlessly into CourseDetailScreen.
  CourseModel toCourseModel() {
    return CourseModel(
      id: id,
      title: title,
      description: description,
      shortDescription: description,
      instructor: 'Edukkit Team',
      price: price,
      priceText: isFree ? 'Free' : (price > 0 ? '₹${price.toInt()}' : 'Included'),
      thumbnailUrl: '',
      assetPath: imageAsset,
      category: category,
      level: level.toUpperCase(),
      rating: rating,
      lessonsCount: lessonCount,
      isFreePreview: isFree,
      isKitIncluded: kitIncluded,
      isPopular: true,
      badgeText: kitIncluded ? 'KIT INCLUDED' : null,
      badgeColorHex: 0xFF10B981,
    );
  }

  factory FeaturedCourseModel.fromJson(Map<String, dynamic> json) {
    return FeaturedCourseModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      imageAsset: json['image_asset'] ?? json['imageAsset'] ?? '',
      level: json['level'] ?? 'Beginner',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      lessonCount: (json['lesson_count'] ?? json['lessonCount'] as num?)?.toInt() ?? 24,
      kitIncluded: json['kit_included'] ?? json['kitIncluded'] ?? true,
      isFree: json['is_free'] ?? json['isFree'] ?? false,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      courseRoute: json['course_route'] ?? json['courseRoute'] ?? '/course-detail',
      isFeatured: json['is_featured'] ?? json['isFeatured'] ?? true,
      order: (json['order'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'imageAsset': imageAsset,
      'level': level,
      'rating': rating,
      'lessonCount': lessonCount,
      'kitIncluded': kitIncluded,
      'isFree': isFree,
      'price': price,
      'courseRoute': courseRoute,
      'isFeatured': isFeatured,
      'order': order,
    };
  }
}
