import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/api_service.dart';

enum ProductStatus { initial, loading, loaded, error }

class ProductProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  ProductStatus _status = ProductStatus.initial;
  List<Product> _products = [];
  Product? _selectedProduct;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  ProductStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  Product? get selectedProduct => _selectedProduct;

  List<Product> get filteredProducts {
    return _products.where((p) {
      final matchesSearch =
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (p.description ?? '')
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'All' || p.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<String> get categories {
    final cats = _products.map((p) => p.category).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }

  Future<void> fetchProducts(String token) async {
    _status = ProductStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _api.getAllProducts(token);
      _status = ProductStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _status = ProductStatus.error;
    }

    notifyListeners();
  }

  Future<void> fetchProductById(String token, int id) async {
    _selectedProduct = null;
    notifyListeners();
    try {
      _selectedProduct = await _api.getProductById(token, id);
    } catch (e) {
      // handled in screen
    }
    notifyListeners();
  }

  Future<bool> createProduct(
      String token, Map<String, dynamic> data) async {
    try {
      final product = await _api.createProduct(token, data);
      _products.insert(0, product);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(
      String token, int id, Map<String, dynamic> data) async {
    try {
      final updated = await _api.updateProduct(token, id, data);
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) _products[index] = updated;
      if (_selectedProduct?.id == id) _selectedProduct = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(String token, int id) async {
    try {
      await _api.deleteProduct(token, id);
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
