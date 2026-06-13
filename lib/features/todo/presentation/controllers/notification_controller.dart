import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_app/core/services/notification_service.dart';
import 'package:todo_app/core/services/notification_service_provider.dart';
import 'package:todo_app/features/todo/data/repositories/todo_repository_provider.dart';
import 'package:todo_app/features/todo/domain/entities/task.dart';

part 'notification_controller.g.dart';

@Riverpod(keepAlive: true)
class NotificationController extends _$NotificationController {
  final Map<String, DateTime> _scheduledTasks = {};
  bool _isInitialized = false;
  bool _isStartupSyncDone = false;

  @override
  Stream<void> build() async* {
    final repository = ref.watch(todoRepositoryProvider);
    final service = ref.watch(notificationServiceProvider);

    // Ensure initialization happens exactly once before scheduling
    if (!_isInitialized) {
      await service.initialize();
      _isInitialized = true;
    }

    // Use asyncMap to await asynchronous synchronization and propagate errors correctly
    yield* repository.watchActiveTasks().asyncMap((tasks) async {
      await _syncNotifications(tasks, service);
    });
  }

  Future<void> _syncNotifications(
    List<Task> tasks,
    NotificationService service,
  ) async {
    // On first startup/rebuild sync, cancel all OS notifications to clear orphaned tasks
    if (!_isStartupSyncDone) {
      try {
        await service.cancelAllNotifications();
        _scheduledTasks.clear();
        _isStartupSyncDone = true;
      } catch (_) {
        // Log startup sync failure
      }
    }

    final activeTaskIds = <String>{};
    final now = DateTime.now();

    for (final task in tasks) {
      final hasFutureDueDate =
          task.dueDate != null && task.dueDate!.isAfter(now);
      final needsNotification =
          hasFutureDueDate &&
          !task.isCompleted &&
          !task.isArchived &&
          !task.isDeleted;

      if (needsNotification) {
        activeTaskIds.add(task.id);
        final scheduledDate = _scheduledTasks[task.id];

        // If not scheduled, or scheduled date changed, schedule/reschedule
        if (scheduledDate == null || scheduledDate != task.dueDate) {
          _scheduledTasks[task.id] = task.dueDate!;
          try {
            await service.scheduleNotification(
              id: task.id,
              title: task.title,
              body: task.description.isNotEmpty
                  ? task.description
                  : 'Task due reminder',
              scheduledTime: task.dueDate!,
            );
          } catch (_) {
            // Log/handle scheduling error for this specific task
          }
        }
      }
    }

    // Cancel notifications for any task that is no longer active or no longer needs it
    final keysToRemove = <String>[];
    for (final taskId in _scheduledTasks.keys) {
      if (!activeTaskIds.contains(taskId)) {
        try {
          await service.cancelNotification(taskId);
          keysToRemove.add(taskId);
        } catch (_) {
          // Log/handle cancellation error
        }
      }
    }
    for (final key in keysToRemove) {
      _scheduledTasks.remove(key);
    }
  }

  /// Manually schedule a notification for a task
  Future<void> scheduleForTask(Task task) async {
    final service = ref.read(notificationServiceProvider);
    if (task.dueDate != null && task.dueDate!.isAfter(DateTime.now())) {
      _scheduledTasks[task.id] = task.dueDate!;
      await service.scheduleNotification(
        id: task.id,
        title: task.title,
        body: task.description.isNotEmpty
            ? task.description
            : 'Task due reminder',
        scheduledTime: task.dueDate!,
      );
    }
  }

  /// Manually cancel a notification for a task
  Future<void> cancelForTask(String taskId) async {
    final service = ref.read(notificationServiceProvider);
    _scheduledTasks.remove(taskId);
    await service.cancelNotification(taskId);
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAll() async {
    final service = ref.read(notificationServiceProvider);
    _scheduledTasks.clear();
    await service.cancelAllNotifications();
  }
}
