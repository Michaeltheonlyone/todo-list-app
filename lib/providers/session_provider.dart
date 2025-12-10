import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/session.dart';

// Sessions provider
final sessionsProvider =
    StateNotifierProvider.family<SessionsNotifier, List<WorkSession>, String>(
      (ref, taskId) => SessionsNotifier(taskId),
    );

class SessionsNotifier extends StateNotifier<List<WorkSession>> {
  final String taskId;

  SessionsNotifier(this.taskId) : super([]) {
    loadSessions();
  }

  Future<void> loadSessions() async {
    try {
      final sessions = await ApiService.getSessions(taskId);
      state = sessions;
    } catch (e) {
      print('Error loading sessions: $e');
      state = [];
    }
  }

  Future<void> addSession(WorkSession session) async {
    try {
      final newSession = await ApiService.createSession(session);
      state = [...state, newSession];
    } catch (e) {
      print('Error adding session: $e');
    }
  }
}
