import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/session.dart';
import 'auth_service.dart';
import 'api_service.dart';

class SessionService {
  static const String baseUrl = ApiService.baseUrl;

  // Get sessions for a task
  static Future<List<WorkSession>> getSessionsForTask(String taskId) async {
    try {
      final userId = await AuthService.getUserId();
      if (userId == null) throw Exception('User not logged in');

      final response = await http.get(
        Uri.parse('$baseUrl/sessions.php?task_id=$taskId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => WorkSession.fromMap(json)).toList();
      } else {
        throw Exception('Failed to load sessions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading sessions: $e');
    }
  }

  // Create a new session
  static Future<WorkSession> createSession(WorkSession session) async {
    try {
      final userId = await AuthService.getUserId();
      if (userId == null) throw Exception('User not logged in');

      final response = await http.post(
        Uri.parse('$baseUrl/sessions.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(session.toMap()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return WorkSession.fromMap(json.decode(response.body));
      } else {
        throw Exception('Failed to create session: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating session: $e');
    }
  }

  // End a session
  static Future<void> endSession(String sessionId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/sessions.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': sessionId,
          'status': SessionStatus.completed.index,
          'endTime': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to end session: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error ending session: $e');
    }
  }
}
