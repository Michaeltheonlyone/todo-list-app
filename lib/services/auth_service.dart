import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  static const String baseUrl = ApiService.baseUrl;

  // Enregistrer
  static Future<bool> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'action': 'register',
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error register: $e');
      return false;
    }
  }

  // Connexion
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'action': 'login',
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _saveUserSession(data['user_id'], data['username']);
        return data;
      }
      return null;
    } catch (e) {
      print('Error login: $e');
      return null;
    }
  }

  // Sauvegarder la session
  static Future<void> _saveUserSession(int userId, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
    await prefs.setString('username', username);
    await prefs.setBool('is_logged_in', true);
  }

  // Obtenir l'utilisateur courant
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  // Déconnexion
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Vérifier si connecté
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final userId = prefs.getInt('user_id');
    return isLoggedIn && userId != null;
  }
}
