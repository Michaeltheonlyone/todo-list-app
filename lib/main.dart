import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import '../models/session.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/endpoints';

  // 1. Get all tasks
  static Future<List<Task>> getTasks() async {
    final response = await http.get(Uri.parse('$baseUrl/tasks.php'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Task.fromMap(json)).toList();
    }
    throw Exception('Failed to load tasks');
  }

  // 2. Create new task
  static Future<Task> createTask(Task task) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(task.toMap()),
    );
    if (response.statusCode == 200) {
      return Task.fromMap(json.decode(response.body));
    }
    throw Exception('Failed to create task');
  }

  // 3. Update existing task
  static Future<void> updateTask(Task task) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tasks.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(task.toMap()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update task');
    }
  }

  // 4. Delete task
  static Future<void> deleteTask(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/tasks.php?id=$id'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete task');
    }
  }

  // 5. Get sessions for a task
  static Future<List<WorkSession>> getSessions(String taskId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/sessions.php?taskId=$taskId'),
    );
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => WorkSession.fromMap(json)).toList();
    }
    return [];
  }
}