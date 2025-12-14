import 'dart:async';
import 'package:flutter/foundation.dart'; // for ValueNotifier
import 'package:audioplayers/audioplayers.dart';
import '../services/api_service.dart';
import '../models/app_notification.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  // Public notifier for UI to listen to
  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  Timer? _timer;
  int _lastKnownMaxId = -1;
  int? _currentUserId;
  final AudioPlayer _audioPlayer = AudioPlayer();

  void init(int userId) {
    if (_currentUserId == userId) return; // Already running for this user
    _currentUserId = userId;
    _lastKnownMaxId = -1; // Reset on new user login
    _startPolling();
  }

  void stop() {
    _timer?.cancel();
    _currentUserId = null;
    _lastKnownMaxId = -1;
  }

  void _startPolling() {
    _timer?.cancel();
    // Check every 5 seconds for better responsiveness
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkNotifications();
    });
    // Also check immediately
    _checkNotifications();
  }

  Future<void> _checkNotifications() async {
    if (_currentUserId == null) return;

    try {
      final notifications = await ApiService.getNotifications(_currentUserId!);
      
      // Update unread count
      final unread = notifications.where((n) => !n.isRead).length;
      unreadCount.value = unread;

      if (notifications.isEmpty) return;

      // Find the highest ID in the list
      // Assuming list is ordered or we find max
      int maxId = notifications.map((n) => n.id).reduce((curr, next) => curr > next ? curr : next);

      // Initialize baseline if first run
      if (_lastKnownMaxId == -1) {
        _lastKnownMaxId = maxId;
        return;
      }

      // If we found a newer ID than what we knew
      if (maxId > _lastKnownMaxId) {
        // Find if any of the NEW items are unread
        final newItems = notifications.where((n) => n.id > _lastKnownMaxId && !n.isRead);
        
        if (newItems.isNotEmpty) {
          _playSound();
        }
        
        _lastKnownMaxId = maxId;
      }
    } catch (e) {
      print('Polling error: $e');
    }
  }

  Future<void> _playSound() async {
    try {
      // Plays a standard notification sound from a URL since we don't have local assets
      // Using a short, reliable "ding" sound
      // Alternatively, we could bundle a sound file if the user adds one to assets/sounds/
      await _audioPlayer.play(UrlSource('https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3'));
      print('🔔 Notification Sound Played');
    } catch (e) {
      print('Error playing sound: $e');
    }
  }
}
