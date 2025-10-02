import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    await _messaging.requestPermission();
    final token = await _messaging.getToken();
    print('FCM Token: $token');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground Notification Received: ${message.notification?.title}, Body: ${message.notification?.body}, Data: ${message.data}');
      _showLocalNotification(message.notification);
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _showLocalNotification(RemoteNotification? notification) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'fcm_channel', 'FCM Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);
    await FlutterLocalNotificationsPlugin().show(
      0,
      notification?.title ?? 'FCM Message',
      notification?.body ?? '',
      details,
    );
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Background Notification Received: ${message.notification?.title}, Body: ${message.notification?.body}, Data: ${message.data}');
  }
}