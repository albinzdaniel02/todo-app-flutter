import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:todo_app/features/todo/data/models/task.dart';
import 'package:todo_app/features/todo/data/models/subtask.dart';
import 'package:todo_app/features/todo/data/repositories/hive_todo_repository.dart';
import 'package:todo_app/features/todo/domain/entities/task.dart';
import 'package:todo_app/features/todo/domain/entities/subtask.dart';

void main() {
  group('HiveTodoRepository Tests', () {
    late Directory tempDir;
    late Box<TaskModel> tasksBox;
    late HiveTodoRepository repository;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('hive_todo_repo_test');
      Hive.init(tempDir.path);

      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(SubtaskModelAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(TaskPriorityModelAdapter());
      }
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(TaskModelAdapter());
      }

      tasksBox = await Hive.openBox<TaskModel>('tasks');
      repository = HiveTodoRepository(tasksBox);
    });

    tearDown(() async {
      await tasksBox.close();
      await Hive.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    final tActiveTask = Task(
      id: 'active-1',
      title: 'Active Task',
      description: 'Active Task Desc',
      isCompleted: false,
      priority: TaskPriority.medium,
      dueDate: DateTime(2026, 6, 15),
      subtasks: const [
        Subtask(id: 'sub-1', title: 'Subtask 1', isCompleted: false),
      ],
      isArchived: false,
      isDeleted: false,
      createdAt: DateTime(2026, 6, 12),
    );

    final tArchivedTask = Task(
      id: 'archived-1',
      title: 'Archived Task',
      description: 'Archived Task Desc',
      isCompleted: false,
      priority: TaskPriority.low,
      dueDate: DateTime(2026, 6, 16),
      subtasks: const [],
      isArchived: true,
      isDeleted: false,
      createdAt: DateTime(2026, 6, 12),
    );

    final tTrashedTask = Task(
      id: 'trashed-1',
      title: 'Trashed Task',
      description: 'Trashed Task Desc',
      isCompleted: true,
      priority: TaskPriority.high,
      dueDate: DateTime(2026, 6, 17),
      subtasks: const [],
      isArchived: false,
      isDeleted: true,
      createdAt: DateTime(2026, 6, 12),
    );

    test('getTasks should return empty list initially', () async {
      final tasks = await repository.getTasks();
      expect(tasks, isEmpty);
    });

    test(
      'saveTask should add/update task in box and getTask should retrieve it',
      () async {
        await repository.saveTask(tActiveTask);

        final retrieved = await repository.getTask(tActiveTask.id);
        expect(retrieved, equals(tActiveTask));

        final tasks = await repository.getTasks();
        expect(tasks, contains(tActiveTask));
      },
    );

    test('deleteTask should remove task permanently from box', () async {
      await repository.saveTask(tActiveTask);
      await repository.deleteTask(tActiveTask.id);

      final retrieved = await repository.getTask(tActiveTask.id);
      expect(retrieved, isNull);

      final tasks = await repository.getTasks();
      expect(tasks, isEmpty);
    });

    test('getActiveTasks should return only active tasks', () async {
      await repository.saveTask(tActiveTask);
      await repository.saveTask(tArchivedTask);
      await repository.saveTask(tTrashedTask);

      final activeTasks = await repository.getActiveTasks();
      expect(activeTasks, contains(tActiveTask));
      expect(activeTasks, isNot(contains(tArchivedTask)));
      expect(activeTasks, isNot(contains(tTrashedTask)));
    });

    test('getArchivedTasks should return only archived tasks', () async {
      await repository.saveTask(tActiveTask);
      await repository.saveTask(tArchivedTask);
      await repository.saveTask(tTrashedTask);

      final archivedTasks = await repository.getArchivedTasks();
      expect(archivedTasks, isNot(contains(tActiveTask)));
      expect(archivedTasks, contains(tArchivedTask));
      expect(archivedTasks, isNot(contains(tTrashedTask)));
    });

    test('getTrashedTasks should return only trashed tasks', () async {
      await repository.saveTask(tActiveTask);
      await repository.saveTask(tArchivedTask);
      await repository.saveTask(tTrashedTask);

      final trashedTasks = await repository.getTrashedTasks();
      expect(trashedTasks, isNot(contains(tActiveTask)));
      expect(trashedTasks, isNot(contains(tArchivedTask)));
      expect(trashedTasks, contains(tTrashedTask));
    });

    test('watchTasks should emit updated list of all tasks', () async {
      final stream = repository.watchTasks();

      final expectation = expectLater(
        stream,
        emitsInOrder([
          isEmpty,
          equals([tActiveTask]),
          equals([tActiveTask, tArchivedTask]),
          equals([tArchivedTask]),
        ]),
      );

      await Future.delayed(Duration.zero);
      await repository.saveTask(tActiveTask);
      await Future.delayed(Duration.zero);
      await repository.saveTask(tArchivedTask);
      await Future.delayed(Duration.zero);
      await repository.deleteTask(tActiveTask.id);

      await expectation;
    });

    test(
      'watchActiveTasks should emit updated list of active tasks only',
      () async {
        final stream = repository.watchActiveTasks();

        final expectation = expectLater(
          stream,
          emitsInOrder([
            isEmpty,
            equals([tActiveTask]),
            equals(
              [tActiveTask],
            ), // when saving archived task, no change in active tasks, but still emits updated list of active tasks which is identical
            isEmpty,
          ]),
        );

        await Future.delayed(Duration.zero);
        await repository.saveTask(tActiveTask);
        await Future.delayed(Duration.zero);
        await repository.saveTask(tArchivedTask);
        await Future.delayed(Duration.zero);
        await repository.deleteTask(tActiveTask.id);

        await expectation;
      },
    );

    test(
      'watchArchivedTasks should emit updated list of archived tasks only',
      () async {
        final stream = repository.watchArchivedTasks();

        final expectation = expectLater(
          stream,
          emitsInOrder([
            isEmpty,
            isEmpty, // when active task is saved
            equals([tArchivedTask]),
            equals([tArchivedTask]), // when active task is deleted
          ]),
        );

        await Future.delayed(Duration.zero);
        await repository.saveTask(tActiveTask);
        await Future.delayed(Duration.zero);
        await repository.saveTask(tArchivedTask);
        await Future.delayed(Duration.zero);
        await repository.deleteTask(tActiveTask.id);

        await expectation;
      },
    );

    test(
      'watchTrashedTasks should emit updated list of trashed tasks only',
      () async {
        final stream = repository.watchTrashedTasks();

        final expectation = expectLater(
          stream,
          emitsInOrder([
            isEmpty,
            isEmpty, // when active task is saved
            equals([tTrashedTask]),
            equals([tTrashedTask]), // when active task is deleted
          ]),
        );

        await Future.delayed(Duration.zero);
        await repository.saveTask(tActiveTask);
        await Future.delayed(Duration.zero);
        await repository.saveTask(tTrashedTask);
        await Future.delayed(Duration.zero);
        await repository.deleteTask(tActiveTask.id);

        await expectation;
      },
    );
  });
}
