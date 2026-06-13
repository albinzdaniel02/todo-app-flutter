import 'notification_service.dart';

class WebNotificationService implements NotificationService {
  const WebNotificationService();

  @override
  Future<bool> initialize() async {
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
    // No-op on native platforms
  }

  @override
  Future<void> cancelNotification(String id) async {
    // No-op on native platforms
  }

  @override
  Future<void> cancelAllNotifications() async {
    // No-op on native platforms
  }
}
