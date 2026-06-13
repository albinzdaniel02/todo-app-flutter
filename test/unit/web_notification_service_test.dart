import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/core/services/web_notification_service.dart';

void main() {
  group('WebNotificationService (Stub on VM) Tests', () {
    late WebNotificationService service;

    setUp(() {
      service = const WebNotificationService();
    });

    test('initialize should return false on non-web platform (VM)', () async {
      final result = await service.initialize();
      expect(result, isFalse);
    });

    test('scheduleNotification should complete without errors on VM', () async {
      await expectLater(
        service.scheduleNotification(
          id: 'test-id',
          title: 'Title',
          body: 'Body',
          scheduledTime: DateTime.now().add(const Duration(minutes: 5)),
        ),
        completes,
      );
    });

    test('cancelNotification should complete without errors on VM', () async {
      await expectLater(service.cancelNotification('test-id'), completes);
    });

    test(
      'cancelAllNotifications should complete without errors on VM',
      () async {
        await expectLater(service.cancelAllNotifications(), completes);
      },
    );
  });
}
