// lib/services/notification_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/app_notification.dart';
import 'auth_service.dart';

class NotificationService {
  static const String baseUrl = 'http://localhost:8000/backend/endpoints';
  // Pour Android: 'http://10.0.2.2/todo_app/backend/endpoints'
  // Pour iOS: 'http://localhost/todo_app/backend/endpoints'

  // GET all notifications
  static Future<List<AppNotification>> getNotifications() async {
    try {
      final userId = await AuthService.getUserId();
      if (userId == null) throw Exception('User not logged in');

      final response = await http.get(
        Uri.parse('$baseUrl/notifications.php?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => AppNotification.fromMap(json)).toList();
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading notifications: $e');
    }
  }

  // PUT mark as read
  static Future<void> markAsRead(int notificationId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notifications.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': notificationId}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark as read: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error marking notification as read: $e');
    }
  }

  // Get unread notifications count
  static Future<int> getUnreadCount() async {
    try {
      final notifications = await getNotifications();
      return notifications.where((n) => !n.isRead).length;
    } catch (e) {
      return 0;
    }
  }

  // Get unread notifications only
  static Future<List<AppNotification>> getUnreadNotifications() async {
    try {
      final notifications = await getNotifications();
      return notifications.where((n) => !n.isRead).toList();
    } catch (e) {
      return [];
    }
  }

  // Mark all as read
  static Future<void> markAllAsRead() async {
    try {
      final notifications = await getUnreadNotifications();
      for (var notification in notifications) {
        await markAsRead(notification.id);
      }
    } catch (e) {
      throw Exception('Error marking all as read: $e');
    }
  }
}