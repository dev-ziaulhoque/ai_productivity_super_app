import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';

const taskKey = 'be.tramckrijte.workmanagerExample';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final notification = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await notification.initialize(initializationSettings);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails('task_channel', 'Task Reminders',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        channelDescription: 'Notifications for task reminders',
        enableVibration: true,
        playSound: true);
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await notification.show(
      0,
      inputData?['title'] as String? ?? 'Task Reminder',
      inputData?['body'] as String? ?? 'Time to work on your task!',
      platformChannelSpecifics,
    );
    return Future.value(true);
  });
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static bool _isInitialized = false;
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    if (_isInitialized) return;
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: true); // Enable debug mode for testing
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await _notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse);
    _isInitialized = true;

    final notificationStatus = await Permission.notification.status;
    if (!notificationStatus.isGranted) {
      await Permission.notification.request();
    }
    final alarmStatus = await Permission.scheduleExactAlarm.status;
    if (!alarmStatus.isGranted) {
      await Permission.scheduleExactAlarm.request();
    }
    print('Notification service initialized');
  }

  Future<void> _onNotificationResponse(NotificationResponse response) async {
    print('Notification tapped: ${response.payload}');
  }

  Future<void> scheduleNotification(int id, String title, String body, DateTime scheduledTime) async {
    final now = DateTime.now();
    if (scheduledTime.isBefore(now)) {
      print('Warning: Scheduled time ($scheduledTime) is in the past. Skipping notification.');
      return;
    }

    await Workmanager().registerOneOffTask(
      "$taskKey$id",
      taskKey,
      inputData: {'title': title, 'body': body},
      initialDelay: scheduledTime.difference(now),
      constraints: Constraints(
        networkType: NetworkType.notRequired,
      ),
    );
    print('Notification scheduled successfully for ID: $id at $scheduledTime');
  }

  Future<void> cancelNotification(int id) async {
    await Workmanager().cancelByUniqueName("$taskKey$id");
    print('Notification cancelled for ID: $id');
  }

  Future<void> showImmediateNotification(int id, String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails('task_channel', 'Task Reminders',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        channelDescription: 'Notifications for task reminders',
        enableVibration: true,
        playSound: true);
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
    print('Immediate notification shown for ID: $id');
  }
}