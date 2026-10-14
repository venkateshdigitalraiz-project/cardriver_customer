import 'package:firebase_messaging/firebase_messaging.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.createdAt,
    super.isRead = false,
    super.type = 'general',
    super.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    if (json['createdAt'] != null) {
      parsedDate = DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now();
    } else if (json['created_at'] != null) {
      parsedDate = DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return NotificationModel(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title']?.toString() ?? 'Notification',
      message: json['message']?.toString() ?? json['body']?.toString() ?? '',
      createdAt: parsedDate,
      isRead: json['isRead'] == true || json['is_read'] == true,
      type: json['type']?.toString() ?? 'general',
      data: json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'type': type,
      'data': data,
    };
  }

  factory NotificationModel.fromRemoteMessage(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;

    final title = notification?.title ??
        data['title']?.toString() ??
        data['heading']?.toString() ??
        data['subject']?.toString() ??
        'New Notification';

    final body = notification?.body ??
        data['message']?.toString() ??
        data['body']?.toString() ??
        data['content']?.toString() ??
        data['description']?.toString() ??
        data['text']?.toString() ??
        'You have a new update';

    final type = data['type']?.toString() ??
        data['category']?.toString() ??
        data['tag']?.toString() ??
        'general';

    return NotificationModel(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: body,
      createdAt: message.sentTime ?? DateTime.now(),
      isRead: false,
      type: type,
      data: data,
    );
  }
}
