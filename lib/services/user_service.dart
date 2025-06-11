import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_endpoints.dart';
import '../models/user.dart';

/// Layanan untuk mengelola pengguna, termasuk login, registrasi, dan pengambilan data pengguna
class UserService {
  static const String tokenKey = 'token';
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';

  /// Login user, return accessToken jika sukses
  Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['accessToken'] != null && data['refreshToken'] != null) {
          await saveTokens(data['accessToken'], data['refreshToken']);
        }
        // Save userId if available
        if (data['user'] != null && data['user']['id'] != null) {
          await saveUserId(data['user']['id'].toString());
        }
        return data['accessToken'] ?? data['token'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Registrasi pengguna baru
  Future<bool> register(User user) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['accessToken'] != null && data['refreshToken'] != null) {
          await saveTokens(data['accessToken'], data['refreshToken']);
        }
        // Save userId if available
        if (data['user'] != null && data['user']['id'] != null) {
          await saveUserId(data['user']['id'].toString());
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Mengambil data pengguna saat ini
  Future<User?> getCurrentUser(String token) async {
    try {
      final response = await http.get(
        Uri.parse(
          (ApiEndpoints.baseUrl + ApiEndpoints.getUser).replaceFirst(
            ':id',
            'me',
          ),
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<void> saveTokens(
    String accessToken,
    String refreshToken,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(accessTokenKey, accessToken);
    await prefs.setString(refreshTokenKey, refreshToken);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(refreshTokenKey);
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(accessTokenKey);
    await prefs.remove(refreshTokenKey);
  }

  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userIdKey, userId);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }

  static Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(userIdKey);
  }

  /// Mengganti access token yang baru menggunakan refresh token
  Future<String?> refreshAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(refreshTokenKey);
      if (refreshToken == null) return null;
      final response = await http.post(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.refreshAccessToken),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['accessToken'];
        if (newAccessToken != null) {
          await saveTokens(newAccessToken, refreshToken);
          return newAccessToken;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Cek apakah user sudah login (token dan refresh token masih ada)
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final access = prefs.getString(accessTokenKey);
    final refresh = prefs.getString(refreshTokenKey);
    return access != null &&
        refresh != null &&
        access.isNotEmpty &&
        refresh.isNotEmpty;
  }
}
