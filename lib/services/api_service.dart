// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import '../models/session.dart';

class ApiService {
  // IMPORTANT: Change localhost par l'IP de ton backend pour mobile
  // Pour Android emulator: 10.0.2.2
  // Pour iOS simulator: localhost
  // Pour vrai device: IP de ton ordinateur (ex: 192.168.1.100)
  static const String baseUrl = 'http://10.0.2.2:8000/endpoints'; // À ajuster selon ton setup

  // 1. Get all tasks
  static Future<List<Task>> getTasks() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tasks.php'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Task.fromMap(json)).toList();
      } else {
        throw Exception('Failed to load tasks: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getTasks: $e');
      throw Exception('Network error: $e');
    }
  }

  // 2. Create new task
  static Future<Task> createTask(Task task) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tasks.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(task.toMap()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> data = json.decode(response.body);
        return Task.fromMap(data);
      } else {
        throw Exception('Failed to create task: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in createTask: $e');
      throw Exception('Network error: $e');
    }
  }

  // 3. Update existing task
  static Future<void> updateTask(Task task) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/tasks.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(task.toMap()),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to update task: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in updateTask: $e');
      throw Exception('Network error: $e');
    }
  }

  // 4. Delete task
  static Future<void> deleteTask(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/tasks.php?id=$id'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete task: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in deleteTask: $e');
      throw Exception('Network error: $e');
    }
  }

  // 5. Get sessions for a task
  static Future<List<WorkSession>> getSessions(String taskId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sessions.php?taskId=$taskId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => WorkSession.fromMap(json)).toList();
      } else {
        print('No sessions found or error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error in getSessions: $e');
      return [];
    }
  }

  // 6. Create a work session
  static Future<WorkSession> createSession(WorkSession session) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sessions.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(session.toMap()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> data = json.decode(response.body);
        return WorkSession.fromMap(data);
      } else {
        throw Exception('Failed to create session: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in createSession: $e');
      throw Exception('Network error: $e');
    }
  }

  // 7. Update session
  static Future<void> updateSession(WorkSession session) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/sessions.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(session.toMap()),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to update session: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in updateSession: $e');
      throw Exception('Network error: $e');
    }
  }
}