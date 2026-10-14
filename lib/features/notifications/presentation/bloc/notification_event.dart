import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_entity.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Initializes Firebase listening, gets token, and fetches stored notifications
class InitializeNotifications extends NotificationEvent {
  const InitializeNotifications();
}

/// Refreshes the list of notifications
class LoadNotifications extends NotificationEvent {
  const LoadNotifications();
}

/// Dispatched when an inbound notification is received via FCM or local stream
class NotificationReceivedEvent extends NotificationEvent {
  final NotificationEntity notification;

  const NotificationReceivedEvent(this.notification);

  @override
  List<Object?> get props => [notification];
}

/// Dispatched to send a notification (test push / in-app notification)
class SendNotificationEvent extends NotificationEvent {
  final String title;
  final String message;
  final String type;
  final Map<String, dynamic>? data;

  const SendNotificationEvent({
    required this.title,
    required this.message,
    this.type = 'general',
    this.data,
  });

  @override
  List<Object?> get props => [title, message, type, data];
}

/// Dispatched to mark a notification as read
class MarkNotificationAsReadEvent extends NotificationEvent {
  final String id;

  const MarkNotificationAsReadEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// Dispatched to clear all notifications
class ClearAllNotificationsEvent extends NotificationEvent {
  const ClearAllNotificationsEvent();
}
