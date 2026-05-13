import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class CloudflareService {
  final Dio _dio = Dio();
  
  // Your actual Cloudflare Worker API endpoint
  final String _apiBaseUrl = "https://edukkit-api.edukkitofficial.workers.dev";
  
  // Later we can implement secure API tokens
  final String _apiToken = "";

  CloudflareService() {
    _dio.options.baseUrl = _apiBaseUrl;
    _dio.options.headers = {
      'Authorization': 'Bearer $_apiToken',
      'Content-Type': 'application/json',
    };
  }

  /// Fetch or create user in Cloudflare D1
  Future<Map<String, dynamic>?> syncUser({
    required String id,
    required String name,
    required String email,
    String? photoUrl,
  }) async {
    try {
      final response = await _dio.post(
        '/sync-user',
        data: {
          'id': id,
          'name': name,
          'email': email,
          'photo_url': photoUrl,
        },
      );
      
      if (response.data['success'] == true) {
        return response.data['user'];
      }
      return null;
    } catch (e) {
      debugPrint("Error syncing user with Cloudflare: $e");
      return null;
    }
  }

  /// Fetch all published courses
  Future<List<dynamic>> getCourses() async {
    try {
      final response = await _dio.get('/courses');
      return response.data['courses'] ?? [];
    } catch (e) {
      debugPrint("Error fetching courses: $e");
      return [];
    }
  }

  /// Add a new course
  Future<bool> addCourse(Map<String, dynamic> courseData) async {
    try {
      final response = await _dio.post('/courses', data: courseData);
      return response.data['success'] == true;
    } catch (e) {
      debugPrint("Error adding course: $e");
      return false;
    }
  }

  /// Fetch lessons for a specific course
  Future<List<dynamic>> getCourseLessons(String courseId) async {
    try {
      final response = await _dio.get('/courses/$courseId/lessons');
      return response.data['lessons'] ?? [];
    } catch (e) {
      debugPrint("Error fetching lessons: $e");
      return [];
    }
  }

  /// Fetch all products (DIY Kits)
  Future<List<dynamic>> getProducts() async {
    try {
      final response = await _dio.get('/products');
      return response.data['products'] ?? [];
    } catch (e) {
      debugPrint("Error fetching products: $e");
      return [];
    }
  }

  /// Add a new product
  Future<bool> addProduct(Map<String, dynamic> productData) async {
    try {
      final response = await _dio.post('/products', data: productData);
      return response.data['success'] == true;
    } catch (e) {
      debugPrint("Error adding product: $e");
      return false;
    }
  }

  /// Fetch notifications for a user
  Future<List<dynamic>> getNotifications(String userId) async {
    try {
      final response = await _dio.get('/notifications/$userId');
      return response.data['notifications'] ?? [];
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
      return [];
    }
  }

  /// Mark notification as read
  Future<bool> markNotificationAsRead(String id) async {
    try {
      final response = await _dio.post('/notifications/read', data: {'id': id});
      return response.data['success'] == true;
    } catch (e) {
      debugPrint("Error marking notification as read: $e");
      return false;
    }
  }

  /// Fetch banners
  Future<List<dynamic>> getBanners() async {
    try {
      final response = await _dio.get('/banners');
      return response.data['banners'] ?? [];
    } catch (e) {
      debugPrint("Error fetching banners: $e");
      return [];
    }
  }

  /// Add a new banner
  Future<bool> addBanner(Map<String, dynamic> bannerData) async {
    try {
      final response = await _dio.post('/banners', data: bannerData);
      return response.data['success'] == true;
    } catch (e) {
      debugPrint("Error adding banner: $e");
      return false;
    }
  }

  /// Fetch all users (Admin only)
  Future<List<dynamic>> getUsers() async {
    try {
      final response = await _dio.get('/users');
      return response.data['users'] ?? [];
    } catch (e) {
      debugPrint("Error fetching users: $e");
      return [];
    }
  }

  /// Update a user's role (Admin only)
  Future<bool> updateUserRole(String id, String role) async {
    try {
      final response = await _dio.post(
        '/users/role',
        data: {'id': id, 'role': role},
      );
      return response.data['success'] == true;
    } catch (e) {
      debugPrint("Error updating user role: $e");
      return false;
    }
  }

  /// Search across courses and products
  Future<Map<String, dynamic>> search(String query) async {
    try {
      final response = await _dio.get('/search', queryParameters: {'q': query});
      return response.data;
    } catch (e) {
      debugPrint("Error searching: $e");
      return {'courses': [], 'products': []};
    }
  }
}


