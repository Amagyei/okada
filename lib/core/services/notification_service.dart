// lib/core/services/notification_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:okada/core/services/auth_service.dart';
import 'package:okada/providers/ride_provider.dart';
import 'package:okada/routes.dart';
import 'package:okada/core/services/websocket_service.dart';
import 'package:okada/data/models/user_model.dart';
import 'package:okada/providers/auth_providers.dart';

// Global navigator key for notifications
final navigatorKey = GlobalKey<NavigatorState>();

// Top-level background handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("[NotificationService] Background message: ${message.messageId}");
  if (message.notification != null) {
    print('[NotificationService] Notification: ${message.notification!.title} - ${message.notification!.body}');
  }
}

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotif = FlutterLocalNotificationsPlugin();
  final AuthService _authService;
  final GlobalKey<NavigatorState> navigatorKey;
  final WebSocketService _websocketService;
  StreamSubscription? _websocketSubscription;
  String? _pendingFcmToken;

  NotificationService({
    required AuthService authService,
    required this.navigatorKey,
    required WebSocketService websocketService,
  }) : _authService = authService,
       _websocketService = websocketService;

  Future<void> initialize() async {
    await Firebase.initializeApp();

    // 1) Create Android notification channel
    const androidChannel = AndroidNotificationChannel(
      'okada_rider_channel',
      'Okada Rider Notifications',
      description: 'Ride updates and alerts',
      importance: Importance.max,
    );
    await _localNotif
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // 2) Init local notifications
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );
    await _localNotif.initialize(initSettings,
        onDidReceiveNotificationResponse: (response) async {
      if (response.payload != null) {
        final data = json.decode(response.payload!);
        _handleDataPayload(data, isForeground: false);
      }
    });

    // 3) Request FCM permissions
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    print('[NotificationService] FCM permission: ${settings.authorizationStatus}');

    // 4) Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 5) Get initial token but don't send to backend yet (wait for login)
    final token = await _fcm.getToken();
    if (token != null) {
      print('[NotificationService] Initial FCM token: $token');
      _pendingFcmToken = token;
    } else {
      print('[NotificationService] Failed to get FCM token');
    }

    // 6) Listen & forward token refresh
    _fcm.onTokenRefresh.listen((newToken) async {
      print('[NotificationService] Token refreshed: $newToken');
      _pendingFcmToken = newToken;
      await _tryUpdateFcmToken(newToken);
    });

    // 7) Foreground message handler
    FirebaseMessaging.onMessage.listen((msg) {
      print('🔥 onMessage received:');
      print('  - Message ID: ${msg.messageId}');
      print('  - Notification: ${msg.notification?.title} / ${msg.notification?.body}');
      print('  - Data: ${msg.data}');
      
      _showLocalNotification(
        msg.notification?.title ?? msg.data['title'] ?? 'New Message',
        msg.notification?.body ?? msg.data['body'],
        msg.data,
      );
      
      _handleDataPayload(msg.data, isForeground: true);
    });

    // 8) When user taps notification (background or terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      print('[NotificationService] Notification tapped: ${msg.data}');
      _handleDataPayload(msg.data, isForeground: false);
      _navigateFromPayload(msg.data);
    });

    // 9) If opened from terminated state
    final initialMsg = await _fcm.getInitialMessage();
    if (initialMsg != null) {
      print('[NotificationService] Launched from notification: ${initialMsg.data}');
      _handleDataPayload(initialMsg.data, isForeground: false);
      _navigateFromPayload(initialMsg.data);
    }
  }

  void _initializeWebSocket() {
    _authService.getUserProfile().then((user) {
      if (user != null) {
        print('🔥 [NotificationService] Initializing WebSocket for user: ${user.id}');
        _websocketService.connect(user.id.toString());
        _websocketSubscription = _websocketService.messages.listen((data) {
          print('🔥 [NotificationService] WebSocket message received: $data');
          if (data['type'] == 'send.notification') {
            final payload = data['payload'];
            print('🔥 [NotificationService] Processing notification payload: $payload');
            _showLocalNotification(
              payload['title'],
              payload['body'],
              payload,
            );
            _handleDataPayload(payload, isForeground: true);
          }
        }, onError: (err) {
          print('🔥 [NotificationService] WebSocket error: $err');
        }, onDone: () {
          print('🔥 [NotificationService] WebSocket connection closed');
        });
      } else {
        print('🔥 [NotificationService] No user found, skipping WebSocket initialization');
      }
    });
  }

  Future<void> _showLocalNotification(String title, String body, Map<String, dynamic> data) async {
    await _localNotif.show(
      data.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'okada_rider_channel',
          'Okada Rider Notifications',
          channelDescription: 'Ride updates and alerts',
          icon: '@mipmap/ic_launcher',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: json.encode(data),
    );
  }

  void _handleDataPayload(Map<String, dynamic> data, {required bool isForeground}) {
    print('[NotificationService] Data payload: $data');

    final rideId = data['ride_id'];
    final type = data['type'];
    if (rideId != null && type != null) {
      final id = int.tryParse('$rideId');
      if (id != null) {
        final container = ProviderScope.containerOf(navigatorKey.currentContext!);
        final notifier = container.read(rideDetailProvider(id).notifier);
        notifier.fetchRideDetails();
      }
    }
  }

  void _navigateFromPayload(Map<String, dynamic> data) {
    final rideId = data['ride_id'];
    if (rideId != null) {
      final id = int.tryParse('$rideId');
      if (id != null) {
        navigatorKey.currentState?.pushNamed(
          AppRoutes.ongoingRide,
          arguments: id,
        );
      }
    }
  }

  void dispose() {
    _websocketSubscription?.cancel();
    _websocketService.dispose();
  }

  // Method to be called when user logs in
  Future<void> onUserLogin() async {
    print('🔥 [NotificationService] ===== onUserLogin() called =====');
    print('🔥 [NotificationService] User logged in, updating FCM token and initializing WebSocket');
    
    // Update FCM token if we have one
    if (_pendingFcmToken != null) {
      print('🔥 [NotificationService] Updating FCM token: $_pendingFcmToken');
      await _tryUpdateFcmToken(_pendingFcmToken!);
    } else {
      print('🔥 [NotificationService] No pending FCM token to update');
    }
    
    // Initialize WebSocket connection
    print('🔥 [NotificationService] Initializing WebSocket connection');
    _initializeWebSocket();
    print('🔥 [NotificationService] ===== onUserLogin() completed =====');
  }

  Future<void> _tryUpdateFcmToken(String token) async {
    try {
      await _authService.updateFcmToken(token);
      print('[NotificationService] FCM token updated successfully');
    } catch (e) {
      print('[NotificationService] Failed to update FCM token: $e');
      // Don't throw - this is not critical for app functionality
    }
  }
}

// Provider for NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final authService = ref.read(authServiceProvider);
  final websocketService = ref.read(websocketServiceProvider);
  return NotificationService(
    authService: authService,
    navigatorKey: navigatorKey,
    websocketService: websocketService,
  );
});


