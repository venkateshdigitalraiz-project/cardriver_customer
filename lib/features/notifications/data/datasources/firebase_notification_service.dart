import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../firebase_options.dart';
import '../models/notification_model.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (_) {}

  debugPrint('🔔 [Background FCM Handler] Message: id=${message.messageId}, data=${message.data}, notif=${message.notification?.title}');

  // If the push message is data-only (no system 'notification' object), Android will not display
  // a status-bar notification by default. We trigger it via local notifications.
  if (message.notification == null) {
    try {
      final title = message.data['title']?.toString() ??
          message.data['heading']?.toString() ??
          message.data['subject']?.toString() ??
          'Car Driver Partner';

      final body = message.data['message']?.toString() ??
          message.data['body']?.toString() ??
          message.data['content']?.toString() ??
          message.data['description']?.toString() ??
          'You have a new update';

      final localNotifications = FlutterLocalNotificationsPlugin();
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);
      await localNotifications.initialize(settings: initSettings);

      const androidDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important ride alerts, updates, and messages.',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
      );
      const details = NotificationDetails(android: androidDetails);

      await localNotifications.show(
        id: message.hashCode,
        title: title,
        body: body,
        notificationDetails: details,
        payload: message.data['type']?.toString(),
      );
    } catch (e) {
      debugPrint('⚠️ [Background FCM Notification Error] $e');
    }
  }
}

class FirebaseNotificationService {
  FirebaseNotificationService._internal();
  static final FirebaseNotificationService instance = FirebaseNotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final StreamController<NotificationModel> _notificationStreamController = StreamController<NotificationModel>.broadcast();

  Stream<NotificationModel> get notificationStream => _notificationStreamController.stream;

  bool _isFirebaseConfigured = false;
  bool get isFirebaseConfigured => _isFirebaseConfigured;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important ride alerts, updates, and messages.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  Future<void> initialize() async {
    // 1. Initialize Local Notifications Plugin and Notification Channel first
    await _initLocalNotifications();

    // 2. Safely attempt Firebase initialization
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _isFirebaseConfigured = true;
      debugPrint('✅ [Firebase] Firebase initialized successfully with driverbooking-4b700');

      // 3. Register background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 4. Request FCM user permissions
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint('🔔 [FCM Permission] Authorization status: ${settings.authorizationStatus}');

      // 5. Set foreground presentation options (displays heads-up banner in foreground)
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 6. Retrieve FCM device token
      try {
        _fcmToken = await messaging.getToken();
        debugPrint('🔑 [FCM Token] $_fcmToken');
        if (_fcmToken != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('fcm_token', _fcmToken!);
        }
      } catch (e) {
        debugPrint('⚠️ [FCM Token] Could not retrieve token: $e');
      }

      // 7. Listen for token refresh
      messaging.onTokenRefresh.listen((newToken) async {
        _fcmToken = newToken;
        debugPrint('🔑 [FCM Token Refreshed] $newToken');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', newToken);
      });

      // 8. Subscribe to common topic channels
      try {
        await messaging.subscribeToTopic('all');
        await messaging.subscribeToTopic('customers');
        debugPrint('✅ [FCM Topics] Subscribed to "all" and "customers" topics');
      } catch (e) {
        debugPrint('⚠️ [FCM Topics] Failed to subscribe: $e');
      }

      // 9. Listen for incoming foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('🔔 [Foreground FCM] ${message.notification?.title}: ${message.notification?.body}');
        final model = NotificationModel.fromRemoteMessage(message);

        // Show heads-up local banner notification on screen
        showNotification(
          id: message.hashCode,
          title: model.title,
          body: model.message,
          payload: model.type,
        );

        // Broadcast to stream
        _notificationStreamController.add(model);
      });

      // 10. Listen for message opened app event (when tapped from background)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('🚀 [FCM Opened From Background] ${message.notification?.title}');
        final model = NotificationModel.fromRemoteMessage(message);
        _notificationStreamController.add(model);
      });

      // 11. Check if app was opened from a terminated state notification
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('🚀 [FCM Opened From Terminated State] ${initialMessage.notification?.title}');
        final model = NotificationModel.fromRemoteMessage(initialMessage);
        _notificationStreamController.add(model);
      }
    } catch (e) {
      _isFirebaseConfigured = false;
      debugPrint('ℹ️ [Firebase Notice] Operating in fallback local notification mode ($e). Note: Add google-services.json to android/app to connect live Google FCM server.');
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _localNotificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('🔔 [Local Notification Clicked] payload: ${response.payload}');
      },
    );

    // Create Android Notification Channel
    final androidImplementation = _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(_channel);
      await androidImplementation.requestNotificationsPermission();
    }
  }

  /// Request runtime permissions from Android & iOS
  Future<bool> requestPermissions() async {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    final androidImplementation = _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Displays an immediate high-priority local notification banner on screen
  Future<void> showNotification({
    int? id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final notificationId = id ?? DateTime.now().millisecondsSinceEpoch.remainder(100000);

    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(body),
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _localNotificationsPlugin.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  /// Triggers a simulated or outbound notification:
  /// Displays the alert banner on screen and emits it to the reactive stream
  Future<NotificationModel> sendOrSimulateNotification({
    required String title,
    required String message,
    String type = 'general',
    Map<String, dynamic>? data,
  }) async {
    final model = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      createdAt: DateTime.now(),
      isRead: false,
      type: type,
      data: data,
    );

    // Show banner on device
    await showNotification(
      title: title,
      body: message,
      payload: type,
    );

    // Broadcast into app's notification stream
    _notificationStreamController.add(model);

    return model;
  }
}
