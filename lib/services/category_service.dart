import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_endpoints.dart';
import '../models/category.dart';
import '../services/user_service.dart';

/// Service class to handle CRUD operations for categories
class CategoryService {
  /// Ambil semua kategori
  Future<List<Category>> getCategories(String token) async {
    try {
      var response = await http.get(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.getCategories),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 401) {
        final newToken = await UserService().refreshAccessToken();
        if (newToken != null) {
          response = await http.get(
            Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.getCategories),
            headers: {
              'Authorization': 'Bearer $newToken',
              'Content-Type': 'application/json',
            },
          );
        }
      }
      if (response.statusCode == 200) {
        final List<dynamic> categoriesJson = jsonDecode(response.body);
        return categoriesJson.map((e) => Category.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Tambah kategori baru
  Future<void> addCategory(Category category, String token) async {
    try {
      var response = await http.post(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.postCategories),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(category.toJson()),
      );
      if (response.statusCode == 401) {
        final newToken = await UserService().refreshAccessToken();
        if (newToken != null) {
          response = await http.post(
            Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.postCategories),
            headers: {
              'Authorization': 'Bearer $newToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(category.toJson()),
          );
        }
      }
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to add category');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Update kategori yang sudah ada
  Future<void> updateCategory(Category category, String token) async {
    try {
      var response = await http.put(
        Uri.parse(
          ApiEndpoints.baseUrl +
              ApiEndpoints.putCategory.replaceFirst(':id', category.id),
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(category.toJson()),
      );
      if (response.statusCode == 401) {
        final newToken = await UserService().refreshAccessToken();
        if (newToken != null) {
          response = await http.put(
            Uri.parse(
              ApiEndpoints.baseUrl +
                  ApiEndpoints.putCategory.replaceFirst(':id', category.id),
            ),
            headers: {
              'Authorization': 'Bearer $newToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(category.toJson()),
          );
        }
      }
      if (response.statusCode != 200) {
        throw Exception('Failed to update category');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Hapus kategori
  Future<void> deleteCategory(String id, String token) async {
    try {
      var response = await http.delete(
        Uri.parse(
          ApiEndpoints.baseUrl +
              ApiEndpoints.deleteCategory.replaceFirst(':id', id),
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 401) {
        final newToken = await UserService().refreshAccessToken();
        if (newToken != null) {
          response = await http.delete(
            Uri.parse(
              ApiEndpoints.baseUrl +
                  ApiEndpoints.deleteCategory.replaceFirst(':id', id),
            ),
            headers: {
              'Authorization': 'Bearer $newToken',
              'Content-Type': 'application/json',
            },
          );
        }
      }
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete category');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
