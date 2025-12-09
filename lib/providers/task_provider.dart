import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/task.dart';

// Tasks provider without AsyncValue complexity
final tasksProvider = StateNotifierProvider<TasksNotifier, List<Task>>((ref) {
  return TasksNotifier();
});

class TasksNotifier extends StateNotifier<List<Task>> {
  TasksNotifier() : super([]) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    try {
      final tasks = await ApiService.getTasks();
      state = tasks;
    } catch (e) {
      print('Error loading tasks: $e');
      state = [];
    }
  }

  Future<void> addTask(Task task) async {
    try {
      final newTask = await ApiService.createTask(task);
      state = [...state, newTask];
    } catch (e) {
      print('Error adding task: $e');
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await ApiService.updateTask(task);
      state = state.map((t) => t.id == task.id ? task : t).toList();
    } catch (e) {
      print('Error updating task: $e');
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await ApiService.deleteTask(id);
      state = state.where((task) => task.id != id).toList();
    } catch (e) {
      print('Error deleting task: $e');
    }
  }
}
