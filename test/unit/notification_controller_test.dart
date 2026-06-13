import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/core/services/notification_service.dart';
import 'package:todo_app/core/services/notification_service_provider.dart';
import 'package:todo_app/features/todo/data/repositories/todo_repository_provider.dart';
import 'package:todo_app/features/todo/domain/entities/task.dart';
import 'package:todo_app/features/todo/presentation/controllers/notification_controller.dart';
import 'package:todo_app/features/todo/domain/repositories/todo_repository.dart';

class FakeTodoRepository implements TodoRepository {
  final List<Task> _tasks = [];
  final StreamController<List<Task>> _controller =
      StreamController<List<Task>>.broadcast();

  @override
  Stream<List<Task>> watchTasks() async* {
    yield List.unmodifiable(_tasks);
    yield* _controller.stream;
  }

  @override
  Stream<List<Task>> watchActiveTasks() async* {
    yield List.unmodifiable(
      _tasks.where((e) => !e.isArchived && !e.isDeleted).toList(),
    );
    yield* _controller.stream.map(
      (list) => list.where((e) => !e.isArchived && !e.isDeleted).toList(),
    );
  }

  @override
  Stream<List<Task>> watchArchivedTasks() async* {
    yield List.unmodifiable(
      _tasks.where((e) => e.isArchived && !e.isDeleted).toList(),
    );
    yield* _controller.stream.map(
      (list) => list.where((e) => e.isArchived && !e.isDeleted).toList(),
    );
  }

  @override
  Stream<List<Task>> watchTrashedTasks() async* {
    yield List.unmodifiable(_tasks.where((e) => e.isDeleted).toList());
    yield* _controller.stream.map(
      (list) => list.where((e) => e.isDeleted).toList(),
    );
  }

  @override
  Future<List<Task>> getTasks() async => List.unmodifiable(_tasks);

  @override
  Future<List<Task>> getActiveTasks() async => List.unmodifiable(
    _tasks.where((e) => !e.isArchived && !e.isDeleted).toList(),
  );

  @override
  Future<List<Task>> getArchivedTasks() async => List.unmodifiable(
    _tasks.where((e) => e.isArchived && !e.isDeleted).toList(),
  );

  @override
  Future<List<Task>> getTrashedTasks() async =>
      List.unmodifiable(_tasks.where((e) => e.isDeleted).toList());

  @override
  Future<Task?> getTask(String id) async {
    for (final task in _tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  @override
  Future<void> saveTask(Task task) async {
    final index = _tasks.indexWhere((element) => element.id == task.id);
    if (index >= 0) {
      _tasks[index] = task;
    } else {
      _tasks.add(task);
    }
    _controller.add(List.unmodifiable(_tasks));
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((element) => element.id == id);
    _controller.add(List.unmodifiable(_tasks));
  }

  void dispose() {
    _controller.close();
  }
}

class FakeNotificationService implements NotificationService {
  bool initialized = false;
  final Map<String, ScheduledNotification> scheduled = {};

  @override
  Future<bool> initialize() async {
    initialized = true;
    return true;
  }

  @override
  Future<void> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    scheduled[id] = ScheduledNotification(
      id: id,
      title: title,
      body: body,
      scheduledTime: scheduledTime,
      payload: payload,
    );
  }

  @override
  Future<void> cancelNotification(String id) async {
    scheduled.remove(id);
  }

  @override
  Future<void> cancelAllNotifications() async {
    scheduled.clear();
  }
}

class ScheduledNotification {
  final String id;
  final String title;
  final String body;
  final DateTime scheduledTime;
  final String? payload;

  ScheduledNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledTime,
    this.payload,
  });
}

void main() {
  group('NotificationController Tests', () {
    late FakeTodoRepository fakeRepository;
    late FakeNotificationService fakeNotificationService;
    late ProviderContainer container;

    setUp(() {
      fakeRepository = FakeTodoRepository();
      fakeNotificationService = FakeNotificationService();
      container = ProviderContainer(
        overrides: [
          todoRepositoryProvider.overrideWithValue(fakeRepository),
          notificationServiceProvider.overrideWithValue(
            fakeNotificationService,
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
      fakeRepository.dispose();
    });

    test('initialization during build', () async {
      // Start listening to the controller
      final subscription = container.listen(
        notificationControllerProvider,
        (previous, next) {},
      );

      // Await next loop to ensure init runs
      await Future.delayed(const Duration(milliseconds: 10));

      expect(fakeNotificationService.initialized, isTrue);
      subscription.close();
    });

    test('schedule notification for task with future due date', () async {
      final subscription = container.listen(
        notificationControllerProvider,
        (previous, next) {},
      );

      final futureDate = DateTime.now().add(const Duration(hours: 2));
      final task = Task(
        id: 'task-1',
        title: 'Task 1',
        description: 'Do it soon',
        dueDate: futureDate,
        createdAt: DateTime.now(),
      );

      await fakeRepository.saveTask(task);
      await Future.delayed(Duration.zero);

      expect(fakeNotificationService.scheduled.containsKey('task-1'), isTrue);
      final scheduled = fakeNotificationService.scheduled['task-1']!;
      expect(scheduled.title, equals('Task 1'));
      expect(scheduled.body, equals('Do it soon'));
      expect(scheduled.scheduledTime, equals(futureDate));

      subscription.close();
    });

    test('does not schedule notification if due date is in the past', () async {
      final subscription = container.listen(
        notificationControllerProvider,
        (previous, next) {},
      );

      final pastDate = DateTime.now().subtract(const Duration(hours: 2));
      final task = Task(
        id: 'task-1',
        title: 'Task 1',
        dueDate: pastDate,
        createdAt: DateTime.now(),
      );

      await fakeRepository.saveTask(task);
      await Future.delayed(Duration.zero);

      expect(fakeNotificationService.scheduled.containsKey('task-1'), isFalse);
      subscription.close();
    });

    test('cancel notification when task is completed', () async {
      final subscription = container.listen(
        notificationControllerProvider,
        (previous, next) {},
      );

      final futureDate = DateTime.now().add(const Duration(hours: 2));
      final task = Task(
        id: 'task-1',
        title: 'Task 1',
        dueDate: futureDate,
        createdAt: DateTime.now(),
      );

      await fakeRepository.saveTask(task);
      await Future.delayed(Duration.zero);
      expect(fakeNotificationService.scheduled.containsKey('task-1'), isTrue);

      // Complete the task
      await fakeRepository.saveTask(task.copyWith(isCompleted: true));
      await Future.delayed(Duration.zero);

      expect(fakeNotificationService.scheduled.containsKey('task-1'), isFalse);
      subscription.close();
    });

    test('cancel notification when task is archived or deleted', () async {
      final subscription = container.listen(
        notificationControllerProvider,
        (previous, next) {},
      );

      final futureDate = DateTime.now().add(const Duration(hours: 2));
      final task = Task(
        id: 'task-1',
        title: 'Task 1',
        dueDate: futureDate,
        createdAt: DateTime.now(),
      );

      await fakeRepository.saveTask(task);
      await Future.delayed(Duration.zero);
      expect(fakeNotificationService.scheduled.containsKey('task-1'), isTrue);

      // Archive task
      await fakeRepository.saveTask(task.copyWith(isArchived: true));
      await Future.delayed(Duration.zero);
      expect(fakeNotificationService.scheduled.containsKey('task-1'), isFalse);

      // Restore and verify scheduled again
      await fakeRepository.saveTask(task.copyWith(isArchived: false));
      await Future.delayed(Duration.zero);
      expect(fakeNotificationService.scheduled.containsKey('task-1'), isTrue);

      // Delete task
      await fakeRepository.saveTask(task.copyWith(isDeleted: true));
      await Future.delayed(Duration.zero);
      expect(fakeNotificationService.scheduled.containsKey('task-1'), isFalse);

      subscription.close();
    });

    test('update notification if due date changes', () async {
      final subscription = container.listen(
        notificationControllerProvider,
        (previous, next) {},
      );

      final date1 = DateTime.now().add(const Duration(hours: 2));
      final task = Task(
        id: 'task-1',
        title: 'Task 1',
        dueDate: date1,
        createdAt: DateTime.now(),
      );

      await fakeRepository.saveTask(task);
      await Future.delayed(Duration.zero);
      expect(
        fakeNotificationService.scheduled['task-1']?.scheduledTime,
        equals(date1),
      );

      // Change due date
      final date2 = DateTime.now().add(const Duration(hours: 4));
      await fakeRepository.saveTask(task.copyWith(dueDate: date2));
      await Future.delayed(Duration.zero);

      expect(
        fakeNotificationService.scheduled['task-1']?.scheduledTime,
        equals(date2),
      );
      subscription.close();
    });

    test('manual helper actions schedule and cancel correctly', () async {
      final subscription = container.listen(
        notificationControllerProvider,
        (previous, next) {},
      );
      final controller = container.read(
        notificationControllerProvider.notifier,
      );

      final futureDate = DateTime.now().add(const Duration(hours: 1));
      final task = Task(
        id: 'manual-1',
        title: 'Manual Task',
        dueDate: futureDate,
        createdAt: DateTime.now(),
      );

      // Save to repository first so the automatic sync doesn't auto-cancel it
      await fakeRepository.saveTask(task);
      await Future.delayed(const Duration(milliseconds: 10));

      // It is already scheduled by the stream. Let's cancel it first.
      await controller.cancelForTask('manual-1');
      expect(
        fakeNotificationService.scheduled.containsKey('manual-1'),
        isFalse,
      );

      // Now test manual schedule
      await controller.scheduleForTask(task);
      expect(fakeNotificationService.scheduled.containsKey('manual-1'), isTrue);
      expect(
        fakeNotificationService.scheduled['manual-1']?.scheduledTime,
        equals(futureDate),
      );

      await controller.cancelForTask('manual-1');
      expect(
        fakeNotificationService.scheduled.containsKey('manual-1'),
        isFalse,
      );

      await controller.scheduleForTask(task);
      expect(fakeNotificationService.scheduled.containsKey('manual-1'), isTrue);

      await controller.cancelAll();
      expect(fakeNotificationService.scheduled.isEmpty, isTrue);

      subscription.close();
    });
  });
}
