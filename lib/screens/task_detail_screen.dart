import 'dart:async';
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/session.dart';
import '../widgets/priority_badge.dart';
import '../widgets/status_badge.dart';
import '../services/api_service.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;

  const TaskDetailScreen({
    Key? key,
    required this.task,
    required this.onDelete,
    required this.onEdit,
    required this.onToggleStatus,
  }) : super(key: key);

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  int _selectedDuration = 25;
  Timer? _sessionTimer;
  int _remainingSeconds = 0;
  bool _sessionActive = false;
  late TextEditingController _durationController;
  bool _showCompleteButton = false; // ADDED

  @override
  void initState() {
    super.initState();
    _durationController = TextEditingController(text: '25');
    _checkExistingSessions(); // ADDED
  }

  // ADDED: Check if task already has completed sessions
  void _checkExistingSessions() async {
    try {
      if (widget.task.id == null) return;

      final sessions = await ApiService.getSessions(widget.task.id!);
      final hasCompletedSessions = sessions.any((s) => s.isCompleted);

      if (hasCompletedSessions && widget.task.status != TaskStatus.completed) {
        setState(() {
          _showCompleteButton = true;
        });
      }
    } catch (e) {
      // Silent fail
    }
  }

  @override
  void dispose() {
    _durationController.dispose();
    _sessionTimer?.cancel();
    super.dispose();
  }

  void _startSession() async {
    try {
      final session = WorkSession(
        taskId: widget.task.id,
        startTime: DateTime.now(),
        durationMinutes: _selectedDuration,
        type: SessionType.work,
        status: SessionStatus.active,
      );

      await ApiService.createSession(session);

      setState(() {
        _remainingSeconds = _selectedDuration * 60;
        _sessionActive = true;
      });

      _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _remainingSeconds--;
        });

        if (_remainingSeconds <= 0) {
          timer.cancel();
          _endSession();
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Erreur: $e')));
    }
  }

  void _endSession() async {
    try {
      if (widget.task.id == null) {
        return;
      }

      final sessions = await ApiService.getSessions(widget.task.id!);
      if (sessions.isEmpty) {
        return;
      }

      final activeSession = sessions.firstWhere(
        (s) => s.endTime == null,
        orElse: () => sessions.last,
      );

      final updatedSession = activeSession.copyWith(
        endTime: DateTime.now(),
        status: SessionStatus.completed,
      );

      await ApiService.updateSession(updatedSession);

      // ADDED: Show complete button
      setState(() {
        _showCompleteButton = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '✅ Session terminée! Vous pouvez marquer la tâche comme complète.',
          ),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (error) {
      // Silent fail
    } finally {
      _sessionTimer?.cancel();
      setState(() {
        _sessionActive = false;
        _remainingSeconds = 0;
      });
    }
  }

  // ADDED: Complete task method
  void _completeTask() async {
    try {
      final updatedTask = widget.task.copyWith(
        status: TaskStatus.completed,
        completedAt: DateTime.now(),
      );

      await ApiService.updateTask(updatedTask);

      widget.onToggleStatus();

      setState(() {
        _showCompleteButton = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Tâche marquée comme terminée!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur: $error'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  String get _timerText {
    final mins = _remainingSeconds ~/ 60;
    final secs = _remainingSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF9333EA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Détails de la tâche',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.task.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.task.description != null &&
                      widget.task.description!.isNotEmpty) ...[
                    const Text(
                      'DESCRIPTION',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.task.description!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PRIORITÉ',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            PriorityBadge(priority: widget.task.priority),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'STATUT',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            StatusBadge(status: widget.task.status),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (widget.task.dueDate != null) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'DATE LIMITE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: widget.task.isOverdue
                              ? Colors.red
                              : Colors.grey[700],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(widget.task.dueDate!),
                          style: TextStyle(
                            fontSize: 16,
                            color: widget.task.isOverdue
                                ? Colors.red
                                : Colors.black87,
                            fontWeight: widget.task.isOverdue
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        if (widget.task.isOverdue) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'En retard',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                  if (widget.task.tags != null &&
                      widget.task.tags!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'TAGS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.task.tags!.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.indigo[50]!, Colors.purple[50]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Session de travail',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _sessionActive ? _timerText : '$_selectedDuration:00',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                        if (!_sessionActive) ...[
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Durée (minutes): '),
                              SizedBox(
                                width: 80,
                                child: TextField(
                                  controller: TextEditingController(
                                    text: _selectedDuration.toString(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    final minutes = int.tryParse(value) ?? 25;
                                    if (minutes > 0 && minutes <= 240) {
                                      setState(() {
                                        _selectedDuration = minutes;
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('min'),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),
                        _sessionActive
                            ? ElevatedButton.icon(
                                onPressed: _endSession,
                                icon: const Icon(Icons.stop),
                                label: const Text('Arrêter la session'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              )
                            : ElevatedButton.icon(
                                onPressed: _startSession,
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Démarrer une session'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4F46E5),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ADDED: Complete Task Button
                  if (_showCompleteButton &&
                      widget.task.status != TaskStatus.completed) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _completeTask,
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Marquer la tâche comme terminée'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        widget.onEdit();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Modifier'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Supprimer la tâche'),
                            content: const Text(
                              'Êtes-vous sûr de vouloir supprimer cette tâche ?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () {
                                  widget.onDelete();
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Supprimer',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Supprimer'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    final weekdays = [
      'lundi',
      'mardi',
      'mercredi',
      'jeudi',
      'vendredi',
      'samedi',
      'dimanche',
    ];

    return '${weekdays[date.weekday - 1]} ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
