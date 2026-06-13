import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_app/core/services/notification_service.dart';
import 'package:todo_app/core/services/notification_service_provider.dart';
import 'package:todo_app/features/todo/data/repositories/todo_repository_provider.dart';
import 'package:todo_app/features/todo/domain/entities/task.dart';

part 'notification_controller.g.dart';

@riverpod
class NotificationController extends _$NotificationController {
  final Map<String, DateTime> _scheduledTasks = {};

  @override
  Stream<void> build() {
    ref.keepAlive();
    final repository = ref.watch(todoRepositoryProvider);
    final service = ref.watch(notificationServiceProvider);

    // Initialize notification service dynamically on controller startup
    service.initialize();

    // Watch active tasks stream
    return repository.watchActiveTasks().map((tasks) {
      _syncNotifications(tasks, service);
    });
  }

  void _syncNotifications(List<Task> tasks, NotificationService service) {
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
          service.scheduleNotification(
            id: task.id,
            title: task.title,
            body: task.description.isNotEmpty
                ? task.description
                : 'Task due reminder',
            scheduledTime: task.dueDate!,
          );
        }
      }
    }

    // Cancel notifications for any task that is no longer active or no longer needs it
    final keysToRemove = <String>[];
    for (final taskId in _scheduledTasks.keys) {
      if (!activeTaskIds.contains(taskId)) {
        service.cancelNotification(taskId);
        keysToRemove.add(taskId);
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
