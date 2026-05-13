import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/cloudflare_service.dart';

class ProductProvider extends ChangeNotifier {
  final CloudflareService _cloudflareService = CloudflareService();
  List<ProductModel> _products = [];
  bool _isLoading = false;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await _cloudflareService.getProducts();
      _products = results.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Error fetching products in provider: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
