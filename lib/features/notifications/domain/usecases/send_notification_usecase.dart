import '../repositories/notification_repository.dart';

class SendNotificationUseCase {
  final NotificationRepository repository;

  SendNotificationUseCase(this.repository);

  Future<void> call({
    required String title,
    required String message,
    String type = 'general',
    Map<String, dynamic>? data,
  }) async {
    return await repository.sendNotification(
      title: title,
      message: message,
      type: type,
      data: data,
    );
  }
}
