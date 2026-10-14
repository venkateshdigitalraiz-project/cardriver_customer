import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications();
  Future<void> sendNotification({
    required String title,
    required String message,
    String type = 'general',
    Map<String, dynamic>? data,
  });
  Future<void> markAsRead(String id);
  Future<void> clearAll();
  Future<String?> getDeviceToken();
  Stream<NotificationEntity> get onNotificationReceived;
  bool get isFirebaseAvailable;
}
