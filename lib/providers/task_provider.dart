// lib/providers/task_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/task.dart';

// Provider pour l'ApiService
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// StateNotifier pour gérer les tâches
class TaskNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final ApiService _apiService;

  TaskNotifier(this._apiService) : super(const AsyncValue.loading()) {
    loadTasks();
  }

  // Charger toutes les tâches
  Future<void> loadTasks() async {
    state = const AsyncValue.loading();
    try {
      final tasks = await _apiService.getTasks();
      state = AsyncValue.data(tasks);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Ajouter une tâche
  Future<void> addTask(Task task) async {
    try {
      await _apiService.createTask(task);
      await loadTasks(); // Recharger la liste
    } catch (e) {
      // Tu peux gérer l'erreur ici ou la propager
      rethrow;
    }
  }

  // Mettre à jour une tâche
  Future<void> updateTask(Task task) async {
    try {
      await _apiService.updateTask(task);

      // Mettre à jour localement sans recharger tout
      state.whenData((tasks) {
        final index = tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          final newTasks = List<Task>.from(tasks);
          newTasks[index] = task;
          state = AsyncValue.data(newTasks);
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  // Supprimer une tâche
  Future<void> deleteTask(String id) async {
    try {
      await _apiService.deleteTask(id);

      // Mettre à jour localement
      state.whenData((tasks) {
        final newTasks = tasks.where((t) => t.id != id).toList();
        state = AsyncValue.data(newTasks);
      });
    } catch (e) {
      rethrow;
    }
  }

  // Marquer une tâche comme complétée
  Future<void> completeTask(String id) async {
    state.whenData((tasks) async {
      final task = tasks.firstWhere((t) => t.id == id);
      final updatedTask = task.copyWith(
        status: TaskStatus.completed,
        completedAt: DateTime.now(),
      );
      await updateTask(updatedTask);
    });
  }

  // Filtrer les tâches
  List<Task> filterTasks({
    TaskStatus? status,
    TaskPriority? priority,
    bool? dueToday,
  }) {
    return state.when(
      data: (tasks) {
        var filtered = tasks;

        if (status != null) {
          filtered = filtered.where((t) => t.status == status).toList();
        }

        if (priority != null) {
          filtered = filtered.where((t) => t.priority == priority).toList();
        }

        if (dueToday == true) {
          filtered = filtered.where((t) => t.isDueToday).toList();
        }

        return filtered;
      },
      loading: () => [],
      error: (_, __) => [],
    );
  }
}

// Provider pour le TaskNotifier
final tasksProvider = StateNotifierProvider<TaskNotifier, AsyncValue<List<Task>>>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return TaskNotifier(apiService);
});