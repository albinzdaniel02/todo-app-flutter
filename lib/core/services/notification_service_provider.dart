import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'notification_service.dart';
import 'mobile_notification_service.dart';
import 'web_notification_service.dart';

part 'notification_service_provider.g.dart';

@riverpod
NotificationService notificationService(NotificationServiceRef ref) {
  if (kIsWeb) {
    return const WebNotificationService();
  } else {
    return MobileNotificationService();
  }
}
