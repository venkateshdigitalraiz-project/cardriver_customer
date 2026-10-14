import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_entity.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> notifications;
  final String? deviceToken;
  final bool isFirebaseConfigured;
  final bool isSending;
  final String? actionFeedback;

  const NotificationLoaded({
    required this.notifications,
    this.deviceToken,
    this.isFirebaseConfigured = false,
    this.isSending = false,
    this.actionFeedback,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationLoaded copyWith({
    List<NotificationEntity>? notifications,
    String? deviceToken,
    bool? isFirebaseConfigured,
    bool? isSending,
    String? actionFeedback,
    bool clearFeedback = false,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      deviceToken: deviceToken ?? this.deviceToken,
      isFirebaseConfigured: isFirebaseConfigured ?? this.isFirebaseConfigured,
      isSending: isSending ?? this.isSending,
      actionFeedback: clearFeedback ? null : (actionFeedback ?? this.actionFeedback),
    );
  }

  @override
  List<Object?> get props => [
        notifications,
        deviceToken,
        isFirebaseConfigured,
        isSending,
        actionFeedback,
      ];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}
