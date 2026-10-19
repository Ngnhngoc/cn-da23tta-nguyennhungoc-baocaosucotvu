import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'auth_user';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_keyUser);
    if (userJson == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(userJson));
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username.trim(),
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data['token'];
        final userModel = UserModel.fromJson(data['user']);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyToken, token);
        await prefs.setString(_keyUser, jsonEncode(userModel.toJson()));

        return {'success': true, 'user': userModel};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Đăng nhập không thành công.'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối máy chủ: $e'};
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUser);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
