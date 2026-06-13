import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:todo_app/core/services/mobile_notification_service.dart';

class MockFlutterLocalNotificationsPlugin extends Fake
    implements FlutterLocalNotificationsPlugin {
  bool initializeCalled = false;
  InitializationSettings? settings;

  bool cancelCalled = false;
  int? cancelledId;

  bool cancelAllCalled = false;

  bool zonedScheduleCalled = false;
  int? scheduledId;
  String? scheduledTitle;
  String? scheduledBody;
  tz.TZDateTime? scheduledDate;
  NotificationDetails? scheduledDetails;
  AndroidScheduleMode? scheduledAndroidScheduleMode;
  String? scheduledPayload;

  @override
  Future<bool?> initialize({
    required InitializationSettings settings,
    onDidReceiveNotificationResponse,
    onDidReceiveBackgroundNotificationResponse,
  }) async {
    initializeCalled = true;
    this.settings = settings;
    return true;
  }

  @override
  Future<void> zonedSchedule({
    required int id,
    String? title,
    String? body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    required AndroidScheduleMode androidScheduleMode,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    zonedScheduleCalled = true;
    scheduledId = id;
    scheduledTitle = title;
    scheduledBody = body;
    this.scheduledDate = scheduledDate;
    scheduledDetails = notificationDetails;
    scheduledAndroidScheduleMode = androidScheduleMode;
    scheduledPayload = payload;
  }

  @override
  Future<void> cancel({required int id, String? tag}) async {
    cancelCalled = true;
    cancelledId = id;
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCalled = true;
  }
}

void main() {
  group('MobileNotificationService Tests', () {
    late MockFlutterLocalNotificationsPlugin mockPlugin;
    late MobileNotificationService service;

    setUp(() {
      mockPlugin = MockFlutterLocalNotificationsPlugin();
      service = MobileNotificationService(plugin: mockPlugin);
    });

    test('initialize should call plugin initialize', () async {
      final result = await service.initialize();

      expect(mockPlugin.initializeCalled, isTrue);
      // Wait, since we are not running on a real Android/iOS device (and kIsWeb is false in desktop tests),
      // mockPlugin.resolvePlatformSpecificImplementation will return null in the test environment,
      // so requestPermissions will return false. Thus result is false.
      expect(result, isFalse);
      expect(mockPlugin.settings, isNotNull);
      expect(mockPlugin.settings!.android, isNotNull);
      expect(mockPlugin.settings!.iOS, isNotNull);
    });

    test(
      'scheduleNotification should call zonedSchedule with correct parameters',
      () async {
        await service.initialize();

        final id = 'test-notification-123';
        final title = 'Test Task';
        final body = 'Time to do your task!';
        final scheduledTime = DateTime.now().add(const Duration(hours: 1));

        await service.scheduleNotification(
          id: id,
          title: title,
          body: body,
          scheduledTime: scheduledTime,
          payload: 'test-payload',
        );

        expect(mockPlugin.zonedScheduleCalled, isTrue);
        expect(mockPlugin.scheduledTitle, title);
        expect(mockPlugin.scheduledBody, body);
        expect(mockPlugin.scheduledPayload, 'test-payload');
        expect(
          mockPlugin.scheduledAndroidScheduleMode,
          AndroidScheduleMode.exactAllowWhileIdle,
        );
        expect(mockPlugin.scheduledDate, isNotNull);
        // Verify timezone of scheduledDate is UTC
        expect(mockPlugin.scheduledDate!.location, tz.UTC);
      },
    );

    test(
      'scheduleNotification should not schedule if scheduledTime is in the past',
      () async {
        await service.initialize();

        final id = 'past-task';
        final title = 'Past Task';
        final body = 'This is in the past';
        final scheduledTime = DateTime.now().subtract(
          const Duration(minutes: 5),
        );

        await service.scheduleNotification(
          id: id,
          title: title,
          body: body,
          scheduledTime: scheduledTime,
        );

        expect(mockPlugin.zonedScheduleCalled, isFalse);
      },
    );

    test('cancelNotification should call cancel with correct ID', () async {
      await service.initialize();

      await service.cancelNotification('456');

      expect(mockPlugin.cancelCalled, isTrue);
      expect(mockPlugin.cancelledId, 456);
    });

    test('cancelAllNotifications should call cancelAll', () async {
      await service.initialize();

      await service.cancelAllNotifications();

      expect(mockPlugin.cancelAllCalled, isTrue);
    });
  });
}
