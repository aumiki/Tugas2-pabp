import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/user.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.12:5000';

  // ─── AUTH ───────────────────────────────────────────────

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Login gagal');
    }
  }

  Future<Map<String, dynamic>> register(
      String fullName, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'fullName': fullName, 'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Registrasi gagal');
    }
  }

  Future<User> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/auth/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return User.fromJson(data['user']);
    } else {
      throw Exception(data['message'] ?? 'Gagal memuat profil');
    }
  }

  Future<void> logout(String refreshToken) async {
    await http.post(
      Uri.parse('$baseUrl/api/auth/logout'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );
  }

  // ─── PRODUCTS ────────────────────────────────────────────

  Future<List<Product>> getAllProducts(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/products'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat produk');
    }
  }

  Future<Product> getProductById(String token, int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/products/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Produk tidak ditemukan');
    }
  }

  Future<Product> createProduct(String token, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/products'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    final responseData = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return Product.fromJson(responseData['product']);
    } else {
      throw Exception(responseData['message'] ?? 'Gagal membuat produk');
    }
  }

  Future<Product> updateProduct(
      String token, int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/products/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return Product.fromJson(responseData['product']);
    } else {
      throw Exception(responseData['message'] ?? 'Gagal memperbarui produk');
    }
  }

  Future<void> deleteProduct(String token, int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/products/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Gagal menghapus produk');
    }
  }
}
