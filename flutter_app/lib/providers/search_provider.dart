import 'dart:async';
import 'package:flutter/material.dart';
import '../models/search_result_model.dart';
import '../services/cloudflare_service.dart';

class SearchProvider with ChangeNotifier {
  final CloudflareService _api = CloudflareService();
  
  List<SearchResult> _searchResults = [];
  List<SearchResult> get searchResults => _searchResults;

  List<String> _recentSearches = [];
  List<String> get recentSearches => _recentSearches;

  final List<String> _trendingSearches = ["Robotics Kit", "AI Course", "IoT Project", "Arduino", "3D Printing"];
  List<String> get trendingSearches => _trendingSearches;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _query = "";
  String get query => _query;

  Timer? _debounce;

  SearchProvider() {
    _recentSearches = ["Robot car", "Python basics", "Drone kit"];
  }

  void updateQuery(String query) {
    _query = query;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        search(query);
      } else {
        _searchResults = [];
        notifyListeners();
      }
    });
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final results = await _api.search(query);
      
      final List<dynamic> courses = results['courses'] ?? [];
      final List<dynamic> products = results['products'] ?? [];

      List<SearchResult> allResults = [];

      for (var course in courses) {
        allResults.add(SearchResult.fromJson(course, SearchResultType.course));
      }

      for (var product in products) {
        allResults.add(SearchResult.fromJson(product, SearchResultType.product));
      }

      _searchResults = allResults;
      
      if (!_recentSearches.contains(query)) {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 10) _recentSearches.removeLast();
      }

    } catch (e) {
      debugPrint("Search error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearHistory() {
    _recentSearches = [];
    notifyListeners();
  }

  void removeSearchHistoryItem(String item) {
    _recentSearches.remove(item);
    notifyListeners();
  }
}
