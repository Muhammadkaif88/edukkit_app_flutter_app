class CourseModel {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final double price;
  final String thumbnailUrl;
  final String category;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.price,
    required this.thumbnailUrl,
    required this.category,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      instructor: json['instructor'] ?? 'Edukkit Team',
      price: (json['price'] as num).toDouble(),
      thumbnailUrl: json['thumbnail_url'] ?? '',
      category: json['category'] ?? 'General',
    );
  }
}
