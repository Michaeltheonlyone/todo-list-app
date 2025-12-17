// lib/screens/pomodoro_timer_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/session.dart';
import '../services/session_service.dart';

class PomodoroTimerScreen extends StatefulWidget {
  final Task task;

  const PomodoroTimerScreen({super.key, required this.task});

  @override
  State<PomodoroTimerScreen> createState() => _PomodoroTimerScreenState();
}

class _PomodoroTimerScreenState extends State<PomodoroTimerScreen> {
  Timer? _timer;
  int _remainingSeconds = 25 * 60; // 25 minutes par défaut
  bool _isRunning = false;
  SessionType _currentType = SessionType.work;
  WorkSession? _currentSession;
  int _completedPomodoros = 0;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadSessions() async {
    try {
      final sessions = await SessionService.getSessionsForTask(widget.task.id!);
      setState(() {
        _completedPomodoros = sessions.where((s) =>
        s.type == SessionType.work && s.status == SessionStatus.completed
        ).length;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  void _startTimer() {
    if (_currentSession == null) {
      _createSession();
    }

    setState(() => _isRunning = true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _onTimerComplete();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _currentType.defaultDuration * 60;
    });
  }

  Future<void> _createSession() async {
    try {
      final session = WorkSession(
        taskId: widget.task.id,
        startTime: DateTime.now(),
        durationMinutes: _currentType.defaultDuration,
        type: _currentType,
        status: SessionStatus.active,
      );

      final createdSession = await SessionService.createSession(session);
      setState(() => _currentSession = createdSession);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _onTimerComplete() async {
    _timer?.cancel();
    setState(() => _isRunning = false);

    // Complete current session
    if (_currentSession != null) {
      try {
        await SessionService.endSession(_currentSession!.id!);
      } catch (e) {
        // Handle error
      }
    }

    // Show completion dialog
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              _currentType == SessionType.work ? Icons.celebration : Icons.coffee,
              color: const Color(0xFF007AFF),
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text('Terminé !'),
          ],
        ),
        content: Text(
          _currentType == SessionType.work
              ? 'Bravo ! Vous avez terminé une session de travail. Prenez une pause !'
              : 'Pause terminée ! Prêt pour une nouvelle session ?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Quitter'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _switchSessionType();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007AFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(_currentType == SessionType.work ? 'Pause' : 'Continuer'),
          ),
        ],
      ),
    );
  }

  void _switchSessionType() {
    setState(() {
      _currentSession = null;

      if (_currentType == SessionType.work) {
        _completedPomodoros++;
        // After 4 pomodoros, take a long break
        if (_completedPomodoros % 4 == 0) {
          _currentType = SessionType.longBreak;
        } else {
          _currentType = SessionType.shortBreak;
        }
      } else {
        _currentType = SessionType.work;
      }

      _remainingSeconds = _currentType.defaultDuration * 60;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Color _getSessionColor() {
    switch (_currentType) {
      case SessionType.work:
        return const Color(0xFF007AFF);
      case SessionType.shortBreak:
        return Colors.green;
      case SessionType.longBreak:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _remainingSeconds / (_currentType.defaultDuration * 60);

    return Scaffold(
      backgroundColor: _getSessionColor(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.task.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Session Type Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                _currentType.label.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),

            const Spacer(),

            // Timer Circle
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 280,
                  height: 280,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),

                Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _formatTime(_remainingSeconds),
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Reset Button
                if (!_isRunning && _remainingSeconds != _currentType.defaultDuration * 60)
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _resetTimer,
                      icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
                      iconSize: 56,
                    ),
                  ),

                // Play/Pause Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _isRunning ? _pauseTimer : _startTimer,
                    icon: Icon(
                      _isRunning ? Icons.pause : Icons.play_arrow,
                      color: _getSessionColor(),
                      size: 48,
                    ),
                    iconSize: 80,
                  ),
                ),

                // Skip Button (only for breaks)
                if (_currentType != SessionType.work)
                  Container(
                    margin: const EdgeInsets.only(left: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        _timer?.cancel();
                        _switchSessionType();
                      },
                      icon: const Icon(Icons.skip_next, color: Colors.white, size: 28),
                      iconSize: 56,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 40),

            // Pomodoros Counter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    '$_completedPomodoros Pomodoros terminés',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}