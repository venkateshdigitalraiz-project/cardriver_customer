import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/firebase_notification_service.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseNotificationService _notificationService;
  static const String _storageKey = 'cardriver_notifications_list_v1';
  StreamSubscription<NotificationModel>? _incomingSubscription;

  NotificationRepositoryImpl({FirebaseNotificationService? notificationService})
      : _notificationService = notificationService ?? FirebaseNotificationService.instance {
    _listenToIncomingNotifications();
  }

  void _listenToIncomingNotifications() {
    _incomingSubscription?.cancel();
    _incomingSubscription = _notificationService.notificationStream.listen((model) async {
      try {
        await _saveNotificationLocally(model);
      } catch (e) {
        debugPrint('⚠️ [NotificationRepository] Error auto-saving notification: $e');
      }
    });
  }

  @override
  Stream<NotificationEntity> get onNotificationReceived => _notificationService.notificationStream;

  @override
  bool get isFirebaseAvailable => _notificationService.isFirebaseConfigured;

  @override
  Future<String?> getDeviceToken() async {
    return _notificationService.fcmToken;
  }

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_storageKey);

      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        final list = decoded.map((item) => NotificationModel.fromJson(item as Map<String, dynamic>)).toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      }

      // Default initial notifications if none stored yet
      final defaultList = [
        NotificationModel(
          id: 'def_1',
          title: 'Welcome to Car Driver Partner! 🚗',
          message: 'Explore hassle-free local and outstation driver bookings with live driver tracking.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
          isRead: false,
          type: 'welcome',
        ),
        NotificationModel(
          id: 'def_2',
          title: 'Booking Confirmed ⚡',
          message: 'Your round trip driver booking #6ace03e49d216 has been scheduled.',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          isRead: true,
          type: 'booking',
        ),
        NotificationModel(
          id: 'def_3',
          title: 'Special Promotion 🎁',
          message: 'Get 20% discount on your next weekend outstation driver booking!',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          isRead: true,
          type: 'promo',
        ),
      ];

      await _saveAllLocally(defaultList);
      return defaultList;
    } catch (e) {
      debugPrint('⚠️ [NotificationRepository] Failed to read stored notifications: $e');
      return [];
    }
  }

  @override
  Future<void> sendNotification({
    required String title,
    required String message,
    String type = 'general',
    Map<String, dynamic>? data,
  }) async {
    final model = await _notificationService.sendOrSimulateNotification(
      title: title,
      message: message,
      type: type,
      data: data,
    );
    await _saveNotificationLocally(model);
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      final current = await getNotifications();
      final updated = current.map((item) {
        if (item.id == id) {
          return item.copyWith(isRead: true);
        }
        return item;
      }).toList();

      await _saveAllLocally(updated);
    } catch (e) {
      debugPrint('⚠️ [NotificationRepository] markAsRead error: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      debugPrint('⚠️ [NotificationRepository] clearAll error: $e');
    }
  }

  Future<void> _saveNotificationLocally(NotificationEntity model) async {
    final current = await getNotifications();
    // Prevent duplicate IDs
    final existingIndex = current.indexWhere((n) => n.id == model.id);
    List<NotificationEntity> updated;
    if (existingIndex >= 0) {
      updated = List.from(current);
      updated[existingIndex] = model;
    } else {
      updated = [model, ...current];
    }
    await _saveAllLocally(updated);
  }

  Future<void> _saveAllLocally(List<NotificationEntity> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = list.map((e) {
        return {
          'id': e.id,
          'title': e.title,
          'message': e.message,
          'createdAt': e.createdAt.toIso8601String(),
          'isRead': e.isRead,
          'type': e.type,
          'data': e.data,
        };
      }).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('⚠️ [NotificationRepository] saveAllLocally error: $e');
    }
  }
}
