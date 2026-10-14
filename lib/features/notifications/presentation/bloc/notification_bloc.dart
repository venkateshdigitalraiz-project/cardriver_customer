import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/usecases/clear_all_notifications_usecase.dart';
import '../../domain/usecases/get_device_token_usecase.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_as_read_usecase.dart';
import '../../domain/usecases/send_notification_usecase.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository notificationRepository;
  final GetNotificationsUseCase getNotificationsUseCase;
  final SendNotificationUseCase sendNotificationUseCase;
  final MarkNotificationAsReadUseCase markNotificationAsReadUseCase;
  final ClearAllNotificationsUseCase clearAllNotificationsUseCase;
  final GetDeviceTokenUseCase getDeviceTokenUseCase;

  StreamSubscription<NotificationEntity>? _notificationSubscription;

  NotificationBloc({
    required this.notificationRepository,
    required this.getNotificationsUseCase,
    required this.sendNotificationUseCase,
    required this.markNotificationAsReadUseCase,
    required this.clearAllNotificationsUseCase,
    required this.getDeviceTokenUseCase,
  }) : super(const NotificationInitial()) {
    on<InitializeNotifications>(_onInitializeNotifications);
    on<LoadNotifications>(_onLoadNotifications);
    on<NotificationReceivedEvent>(_onNotificationReceived);
    on<SendNotificationEvent>(_onSendNotification);
    on<MarkNotificationAsReadEvent>(_onMarkNotificationAsRead);
    on<ClearAllNotificationsEvent>(_onClearAllNotifications);
  }

  Future<void> _onInitializeNotifications(
    InitializeNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());
    try {
      // 1. Subscribe to incoming notifications stream
      await _notificationSubscription?.cancel();
      _notificationSubscription = notificationRepository.onNotificationReceived.listen((notification) {
        add(NotificationReceivedEvent(notification));
      });

      // 2. Fetch device token & stored notifications in parallel
      final token = await getDeviceTokenUseCase();
      final notifications = await getNotificationsUseCase();

      emit(NotificationLoaded(
        notifications: notifications,
        deviceToken: token,
        isFirebaseConfigured: notificationRepository.isFirebaseAvailable,
      ));
    } catch (e) {
      emit(NotificationError('Failed to initialize notifications: $e'));
    }
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final notifications = await getNotificationsUseCase();
      if (state is NotificationLoaded) {
        final current = state as NotificationLoaded;
        emit(current.copyWith(notifications: notifications, clearFeedback: true));
      } else {
        final token = await getDeviceTokenUseCase();
        emit(NotificationLoaded(
          notifications: notifications,
          deviceToken: token,
          isFirebaseConfigured: notificationRepository.isFirebaseAvailable,
        ));
      }
    } catch (e) {
      emit(NotificationError('Failed to load notifications: $e'));
    }
  }

  void _onNotificationReceived(
    NotificationReceivedEvent event,
    Emitter<NotificationState> emit,
  ) {
    if (state is NotificationLoaded) {
      final current = state as NotificationLoaded;
      final currentList = current.notifications;
      final existingIndex = currentList.indexWhere((n) => n.id == event.notification.id);

      List<NotificationEntity> updatedList;
      if (existingIndex >= 0) {
        updatedList = List.from(currentList);
        updatedList[existingIndex] = event.notification;
      } else {
        updatedList = [event.notification, ...currentList];
      }

      emit(current.copyWith(notifications: updatedList));
    } else {
      emit(NotificationLoaded(
        notifications: [event.notification],
        deviceToken: null,
        isFirebaseConfigured: notificationRepository.isFirebaseAvailable,
      ));
    }
  }

  Future<void> _onSendNotification(
    SendNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final current = state as NotificationLoaded;
      emit(current.copyWith(isSending: true, clearFeedback: true));

      try {
        await sendNotificationUseCase(
          title: event.title,
          message: event.message,
          type: event.type,
          data: event.data,
        );

        // Fetch refreshed notifications
        final updatedList = await getNotificationsUseCase();
        emit(current.copyWith(
          isSending: false,
          notifications: updatedList,
          actionFeedback: 'Notification sent and broadcast successfully!',
        ));
      } catch (e) {
        emit(current.copyWith(
          isSending: false,
          actionFeedback: 'Failed to send notification: $e',
        ));
      }
    }
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final current = state as NotificationLoaded;
      // Optimistic update
      final updatedList = current.notifications.map((n) {
        if (n.id == event.id) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();

      emit(current.copyWith(notifications: updatedList));

      try {
        await markNotificationAsReadUseCase(event.id);
      } catch (_) {}
    }
  }

  Future<void> _onClearAllNotifications(
    ClearAllNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final current = state as NotificationLoaded;
      emit(current.copyWith(notifications: [], actionFeedback: 'All notifications cleared'));
      try {
        await clearAllNotificationsUseCase();
      } catch (_) {}
    }
  }

  @override
  Future<void> close() {
    _notificationSubscription?.cancel();
    return super.close();
  }
}
