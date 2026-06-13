import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'notification_service.dart';

@JS('window.Notification')
external JSAny? get _notificationConstructor;

bool get _isNotificationSupported => _notificationConstructor != null;

class WebNotificationService implements NotificationService {
  static final Map<String, Timer> _scheduledTimers = {};

  const WebNotificationService();

  @override
  Future<bool> initialize() async {
    // Check if the Notification API is supported by the browser
    if (!_isNotificationSupported) {
      return false;
    }

    // Check if permission is already granted
    final currentPermission = web.Notification.permission;
    if (currentPermission == 'granted') {
      return true;
    } else if (currentPermission == 'denied') {
      return false;
    }

    // Otherwise request permission
    try {
      final permissionResult =
          await web.Notification.requestPermission().toDart;
      final permissionString = permissionResult.toDart;
      return permissionString == 'granted';
    } catch (_) {
      // Fallback/ignore if requestPermission throws (e.g. not called in response to user interaction)
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
    // Cancel existing timer for this notification if any
    await cancelNotification(id);

    final now = DateTime.now();
    if (scheduledTime.isBefore(now)) {
      // Do not schedule notifications in the past
      return;
    }

    final delay = scheduledTime.difference(now);

    final timer = Timer(delay, () {
      _showNotification(title, body, payload);
      _scheduledTimers.remove(id);
    });

    _scheduledTimers[id] = timer;
  }

  @override
  Future<void> cancelNotification(String id) async {
    final timer = _scheduledTimers.remove(id);
    timer?.cancel();
  }

  @override
  Future<void> cancelAllNotifications() async {
    for (final timer in _scheduledTimers.values) {
      timer.cancel();
    }
    _scheduledTimers.clear();
  }

  void _showNotification(String title, String body, String? payload) {
    if (!_isNotificationSupported) {
      return;
    }

    if (web.Notification.permission == 'granted') {
      final options = web.NotificationOptions(body: body);
      final notification = web.Notification(title, options);

      // Focus window on click
      notification.addEventListener(
        'click',
        (web.Event event) {
          try {
            web.window.focus();
          } catch (_) {}
        }.toJS,
      );
    }
  }
}
