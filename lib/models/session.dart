// lib/models/session.dart

class WorkSession {
  final String? id;
  final String? taskId;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationMinutes; // Durée prévue
  final SessionType type;
  final SessionStatus status;
  final String? notes;

  WorkSession({
    this.id,
    this.taskId,
    required this.startTime,
    this.endTime,
    this.durationMinutes = 25, // 25 min par défaut (Pomodoro)
    this.type = SessionType.work,
    this.status = SessionStatus.planned,
    this.notes,
  });

  // Durée réelle de la session en minutes
  int? get actualDuration {
    if (endTime == null) return null;
    return endTime!.difference(startTime).inMinutes;
  }

  // Vérifie si la session est en cours
  bool get isActive => status == SessionStatus.active;

  // Vérifie si la session est terminée
  bool get isCompleted => status == SessionStatus.completed;

  // Copy with
  WorkSession copyWith({
    String? id,
    String? taskId,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    SessionType? type,
    SessionStatus? status,
    String? notes,
  }) {
    return WorkSession(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      type: type ?? this.type,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  // Conversion vers Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationMinutes': durationMinutes,
      'type': type.index,
      'status': status.index,
      'notes': notes,
    };
  }

  // Création depuis Map
  factory WorkSession.fromMap(Map<String, dynamic> map) {
    return WorkSession(
      id: map['id'],
      taskId: map['taskId'],
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      durationMinutes: map['durationMinutes'] ?? 25,
      type: SessionType.values[map['type'] ?? 0],
      status: SessionStatus.values[map['status'] ?? 0],
      notes: map['notes'],
    );
  }
}

// Type de session (Pomodoro)
enum SessionType {
  work,
  shortBreak,
  longBreak;

  String get label {
    switch (this) {
      case SessionType.work:
        return 'Travail';
      case SessionType.shortBreak:
        return 'Pause courte';
      case SessionType.longBreak:
        return 'Pause longue';
    }
  }

  int get defaultDuration {
    switch (this) {
      case SessionType.work:
        return 25;
      case SessionType.shortBreak:
        return 5;
      case SessionType.longBreak:
        return 15;
    }
  }
}

// Statut de la session
enum SessionStatus {
  planned,
  active,
  paused,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case SessionStatus.planned:
        return 'Planifiée';
      case SessionStatus.active:
        return 'En cours';
      case SessionStatus.paused:
        return 'En pause';
      case SessionStatus.completed:
        return 'Terminée';
      case SessionStatus.cancelled:
        return 'Annulée';
    }
  }
}