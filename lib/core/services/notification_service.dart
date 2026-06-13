abstract class NotificationService {
  /// Request permissions and initialize notification channels.
  /// Returns [true] if permission is granted, [false] otherwise.
  Future<bool> initialize();

  /// Schedule a notification for a task at a specific time.
  /// An optional [payload] can be provided to handle navigation or pass data when the notification is clicked.
  Future<void> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  });

  /// Cancel a scheduled notification.
  Future<void> cancelNotification(String id);

  /// Cancel all scheduled notifications.
  Future<void> cancelAllNotifications();
}
