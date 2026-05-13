enum SearchResultType { course, product, video, teacher, category }

class SearchResult {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String category;
  final double rating;
  final double? price;
  final SearchResultType type;
  final Map<String, dynamic> data; // Original data

  SearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.category,
    required this.rating,
    this.price,
    required this.type,
    required this.data,
  });

  factory SearchResult.fromJson(Map<String, dynamic> data, SearchResultType type) {
    
    String title = "";
    String subtitle = "";
    String imageUrl = "";
    String category = "";
    double rating = 0.0;
    double? price;

    switch (type) {
      case SearchResultType.course:
        title = data['title'] ?? data['name'] ?? '';
        subtitle = data['description'] ?? data['subtitle'] ?? '';
        imageUrl = data['thumbnail'] ?? data['image'] ?? '';
        category = data['category'] ?? 'Course';
        rating = (data['rating'] ?? 0.0).toDouble();
        break;
      case SearchResultType.product:
        title = data['title'] ?? data['name'] ?? '';
        subtitle = data['description'] ?? '';
        imageUrl = data['image_url'] ?? data['image'] ?? data['thumbnail'] ?? '';
        category = data['category'] ?? 'Product';
        rating = (data['rating'] ?? 0.0).toDouble();
        price = (data['price'] ?? 0.0).toDouble();
        break;
      case SearchResultType.video:
        title = data['title'] ?? '';
        subtitle = data['description'] ?? '';
        imageUrl = data['thumbnail'] ?? '';
        category = data['category'] ?? 'Video';
        rating = (data['rating'] ?? 0.0).toDouble();
        break;
      case SearchResultType.teacher:
        title = data['name'] ?? '';
        subtitle = data['bio'] ?? data['subject'] ?? '';
        imageUrl = data['profileImage'] ?? data['image'] ?? '';
        category = data['subject'] ?? 'Teacher';
        rating = (data['rating'] ?? 0.0).toDouble();
        break;
      case SearchResultType.category:
        title = data['name'] ?? '';
        subtitle = data['description'] ?? '';
        imageUrl = data['icon'] ?? '';
        category = 'Category';
        rating = 0.0;
        break;
    }

    return SearchResult(
      id: data['id'] ?? '',
      title: title,
      subtitle: subtitle,
      imageUrl: imageUrl,
      category: category,
      rating: rating,
      price: price,
      type: type,
      data: data,
    );
  }
}
