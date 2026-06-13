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
    // Initialize timezone database (required before scheduling notifications)
    tz.initializeTimeZones();

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

    try {
      final initialized =
          await _plugin.initialize(settings: initializationSettings) ?? false;

      if (!initialized) {
        return false;
      }

      // Request permissions dynamically
      return await requestPermissions();
    } catch (_) {
      return false;
    }
  }

  /// Explicitly request notification permissions from the user.
  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;

    try {
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
              await androidImplementation.requestExactAlarmsPermission() ??
              false;
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
    } catch (_) {
      // Return false if permission requests fail/throw
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

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'task_reminders_channel',
        'Task Reminders',
        channelDescription: 'Notifications for task reminders and due dates',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    try {
      // Try scheduling exact alarm (which requires exact alarm permission on Android)
      await _plugin.zonedSchedule(
        id: intId,
        title: title,
        body: body,
        scheduledDate: tzScheduledTime,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
    } catch (_) {
      // Fallback to inexact scheduling if exact alarm permission is missing/denied
      try {
        await _plugin.zonedSchedule(
          id: intId,
          title: title,
          body: body,
          scheduledDate: tzScheduledTime,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: payload,
        );
      } catch (_) {
        // Fall back gracefully
      }
    }
  }

  @override
  Future<void> cancelNotification(String id) async {
    if (kIsWeb) return;
    try {
      final intId = _notificationId(id);
      await _plugin.cancel(id: intId);
    } catch (_) {
      // Graceful error handling
    }
  }

  @override
  Future<void> cancelAllNotifications() async {
    if (kIsWeb) return;
    try {
      await _plugin.cancelAll();
    } catch (_) {
      // Graceful error handling
    }
  }

  /// Maps a String ID to a stable 31-bit positive integer for the notification ID.
  /// Uses a deterministic Djb2 hashing algorithm to avoid unstable Dart hash codes.
  int _notificationId(String id) {
    final parsed = int.tryParse(id);
    if (parsed != null) return parsed;

    int hash = 5381;
    for (int i = 0; i < id.length; i++) {
      hash = ((hash << 5) + hash) + id.codeUnitAt(i);
      hash = hash & 0xFFFFFFFF;
    }
    return hash & 0x7FFFFFFF;
  }
}
