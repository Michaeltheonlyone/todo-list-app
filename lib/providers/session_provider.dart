// lib/providers/session_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/session.dart';

class SessionNotifier extends StateNotifier<AsyncValue<List<WorkSession>>> {
  final ApiService _apiService;
  final String? _taskId;

  SessionNotifier(this._apiService, {String? taskId})
      : _taskId = taskId,
        super(const AsyncValue.loading()) {
    loadSessions();
  }

  // Charger les sessions
  Future<void> loadSessions() async {
    state = const AsyncValue.loading();
    try {
      List<WorkSession> sessions;
      if (_taskId != null) {
        sessions = await _apiService.getSessions(_taskId!);
      } else {
        // Si pas de taskId, on pourrait charger toutes les sessions
        sessions = [];
      }
      state = AsyncValue.data(sessions);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Démarrer une session
  Future<void> startSession(WorkSession session) async {
    try {
      final startedSession = await _apiService.createSession(session);

      // Ajouter à la liste
      state.whenData((sessions) {
        final newSessions = List<WorkSession>.from(sessions);
        newSessions.add(startedSession);
        state = AsyncValue.data(newSessions);
      });
    } catch (e) {
      rethrow;
    }
  }

  // Terminer une session
  Future<void> endSession(String sessionId) async {
    state.whenData((sessions) async {
      final session = sessions.firstWhere((s) => s.id == sessionId);
      final endedSession = session.copyWith(
        endTime: DateTime.now(),
        status: SessionStatus.completed,
      );

      await _apiService.updateSession(endedSession);

      // Mettre à jour localement
      final index = sessions.indexWhere((s) => s.id == sessionId);
      if (index != -1) {
        final newSessions = List<WorkSession>.from(sessions);
        newSessions[index] = endedSession;
        state = AsyncValue.data(newSessions);
      }
    });
  }
}

// Provider pour les sessions (avec taskId optionnel)
final sessionsProvider = StateNotifierProvider.family<SessionNotifier, AsyncValue<List<WorkSession>>, String?>(
      (ref, taskId) {
    final apiService = ref.read(apiServiceProvider);
    return SessionNotifier(apiService, taskId: taskId);
  },
);