import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'notification_service.dart';

class MobileNotificationService implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;

  MobileNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  @override
  Future<bool> initialize() async {
    // Initialize timezone database
    tz.initializeTimeZones();
    try {
      // Set to UTC as default timezone for absolute scheduling
      tz.setLocalLocation(tz.UTC);
    } catch (_) {
      // Ignored
    }

    if (kIsWeb) {
      return false;
    }

    const initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    final initialized =
        await _plugin.initialize(settings: initializationSettings) ?? false;

    if (!initialized) {
      return false;
    }

    // Request permissions dynamically
    return await requestPermissions();
  }

  /// Explicitly request notification permissions from the user.
  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;

    if (Platform.isAndroid) {
      final androidImplementation = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidImplementation != null) {
        final notificationsGranted =
            await androidImplementation.requestNotificationsPermission() ??
            false;
        // Request exact alarms permission for Android 13+ scheduling
        final exactAlarmGranted =
            await androidImplementation.requestExactAlarmsPermission() ?? false;
        return notificationsGranted && exactAlarmGranted;
      }
    } else if (Platform.isIOS) {
      final iosImplementation = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (iosImplementation != null) {
        return await iosImplementation.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }
    }
    return false;
  }

  @override
  Future<void> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    if (kIsWeb) return;

    if (scheduledTime.isBefore(DateTime.now())) {
      // Don't schedule notifications in the past
      return;
    }

    final intId = _notificationId(id);
    final tzScheduledTime = tz.TZDateTime.from(scheduledTime.toUtc(), tz.UTC);

    await _plugin.zonedSchedule(
      id: intId,
      title: title,
      body: body,
      scheduledDate: tzScheduledTime,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders_channel',
          'Task Reminders',
          channelDescription: 'Notifications for task reminders and due dates',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  @override
  Future<void> cancelNotification(String id) async {
    if (kIsWeb) return;
    final intId = _notificationId(id);
    await _plugin.cancel(id: intId);
  }

  @override
  Future<void> cancelAllNotifications() async {
    if (kIsWeb) return;
    await _plugin.cancelAll();
  }

  /// Maps a String ID to a unique 32-bit positive integer for the notification ID.
  int _notificationId(String id) {
    final parsed = int.tryParse(id);
    if (parsed != null) return parsed;
    return id.hashCode & 0x7FFFFFFF;
  }
}
