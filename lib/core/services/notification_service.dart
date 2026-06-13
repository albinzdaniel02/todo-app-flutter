abstract class NotificationService {
  /// Request permissions and initialize notification channels.
  /// Returns [true] if permission is granted, [false] otherwise.
  Future<bool> initialize();

  /// Schedule a notification for a task at a specific time.
  Future<void> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  });

  /// Cancel a scheduled notification.
  Future<void> cancelNotification(String id);

  /// Cancel all scheduled notifications.
  Future<void> cancelAllNotifications();
}
