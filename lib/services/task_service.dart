// lib/services/task_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import 'auth_service.dart';

class TaskService {
  static const String baseUrl = 'http://localhost:8000/backend/endpoints';
  // Pour un appareil Android: 'http://10.0.2.2/todo_app/backend/endpoints'
  // Pour un appareil iOS: 'http://localhost/todo_app/backend/endpoints'

  // GET all tasks
  static Future<List<Task>> getTasks() async {
    try {
      final userId = await AuthService.getUserId();
      if (userId == null) throw Exception('User not logged in');

      final response = await http.get(
        Uri.parse('$baseUrl/tasks.php?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Task.fromMap(json)).toList();
      } else {
        throw Exception('Failed to load tasks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading tasks: $e');
    }
  }

  // POST create task
  static Future<Task> createTask(Task task) async {
    try {
      final userId = await AuthService.getUserId();
      if (userId == null) throw Exception('User not logged in');

      final taskData = task.toMap();
      taskData['user_id'] = userId;

      final response = await http.post(
        Uri.parse('$baseUrl/tasks.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(taskData),
      );

      if (response.statusCode == 200) {
        return Task.fromMap(json.decode(response.body));
      } else {
        throw Exception('Failed to create task: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating task: $e');
    }
  }

  // PUT update task
  static Future<void> updateTask(Task task) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/tasks.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(task.toMap()),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update task: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating task: $e');
    }
  }

  // DELETE task
  static Future<void> deleteTask(String taskId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/tasks.php?id=$taskId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete task: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting task: $e');
    }
  }

  // Get tasks by status
  static Future<List<Task>> getTasksByStatus(TaskStatus status) async {
    final tasks = await getTasks();
    return tasks.where((task) => task.status == status).toList();
  }

  // Get overdue tasks
  static Future<List<Task>> getOverdueTasks() async {
    final tasks = await getTasks();
    return tasks.where((task) => task.isOverdue).toList();
  }

  // Get tasks due today
  static Future<List<Task>> getTasksDueToday() async {
    final tasks = await getTasks();
    return tasks.where((task) => task.isDueToday).toList();
  }
}