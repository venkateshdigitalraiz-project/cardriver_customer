import '../repositories/notification_repository.dart';

class ClearAllNotificationsUseCase {
  final NotificationRepository repository;

  ClearAllNotificationsUseCase(this.repository);

  Future<void> call() async {
    return await repository.clearAll();
  }
}
