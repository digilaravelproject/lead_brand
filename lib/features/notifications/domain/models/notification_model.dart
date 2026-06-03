class NotificationResponse {
  final String status;
  final int unreadCount;
  final List<NotificationModel> notifications;

  NotificationResponse({
    required this.status,
    required this.unreadCount,
    required this.notifications,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      status: json['status'] ?? '',
      unreadCount: json['unread_count'] ?? 0,
      notifications: json['notifications'] != null
          ? List<NotificationModel>.from(
              json['notifications'].map((x) => NotificationModel.fromJson(x)))
          : [],
    );
  }
}

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String type;
  bool isRead;
  final String createdAt;
  final String updatedAt;
  final String timeAgo;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
    required this.timeAgo,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      timeAgo: json['time_ago'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'is_read': isRead,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'time_ago': timeAgo,
    };
  }
}
