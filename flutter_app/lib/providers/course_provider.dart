import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../services/cloudflare_service.dart';

class CourseProvider extends ChangeNotifier {
  final CloudflareService _cloudflareService = CloudflareService();
  List<CourseModel> _courses = [];
  bool _isLoading = false;

  List<CourseModel> get courses => _courses;
  bool get isLoading => _isLoading;

  Future<void> fetchCourses() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await _cloudflareService.getCourses();
      _courses = results.map((json) => CourseModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Error fetching courses in provider: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
