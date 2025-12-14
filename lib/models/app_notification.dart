class AppNotification {
  final int id;
  final int userId;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] is int ? map['id'] : int.parse(map['id'].toString()),
      userId: map['user_id'] is int ? map['user_id'] : int.parse(map['user_id'].toString()),
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      isRead: map['is_read'] is bool 
          ? map['is_read'] 
          : (map['is_read'].toString() == '1' || map['is_read'].toString() == 'true'),
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : DateTime.now(),
    );
  }
}
