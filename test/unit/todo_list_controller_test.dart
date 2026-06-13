import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/features/todo/data/repositories/todo_repository_provider.dart';
import 'package:todo_app/features/todo/domain/entities/task.dart';
import 'package:todo_app/features/todo/domain/entities/subtask.dart';
import 'package:todo_app/features/todo/domain/repositories/todo_repository.dart';
import 'package:todo_app/features/todo/presentation/controllers/todo_list_controller.dart';

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

void main() {
  group('TodoListController Tests', () {
    late FakeTodoRepository fakeRepository;
    late ProviderContainer container;

    setUp(() {
      fakeRepository = FakeTodoRepository();
      container = ProviderContainer(
        overrides: [todoRepositoryProvider.overrideWithValue(fakeRepository)],
      );
    });

    tearDown(() {
      container.dispose();
      fakeRepository.dispose();
    });

    test('build should watch active tasks by default', () async {
      final states = <List<Task>>[];
      final subscription = container.listen<AsyncValue<List<Task>>>(
        todoListControllerProvider,
        (previous, next) {
          next.whenData((value) => states.add(value));
        },
        fireImmediately: true,
      );

      await Future.delayed(Duration.zero);
      expect(states, [isEmpty]);

      final activeTask = Task(
        id: '1',
        title: 'Active task',
        createdAt: DateTime.now(),
      );
      final archivedTask = Task(
        id: '2',
        title: 'Archived task',
        isArchived: true,
        createdAt: DateTime.now(),
      );

      await fakeRepository.saveTask(activeTask);
      await fakeRepository.saveTask(archivedTask);

      await Future.delayed(Duration.zero);
      expect(states, [
        isEmpty,
        equals([activeTask]),
        equals([activeTask]),
      ]);

      subscription.close();
    });

    test('addTask should save a new task through repository', () async {
      final subscription = container.listen(
        todoListControllerProvider,
        (previous, next) {},
      );
      final controller = container.read(todoListControllerProvider.notifier);

      final dueDate = DateTime(2026, 6, 20);
      final subtasks = [
        const Subtask(id: 'sub-1', title: 'Subtask 1', isCompleted: false),
      ];

      await controller.addTask(
        title: 'New Task',
        description: 'New Description',
        categoryId: 'cat-1',
        priority: 'high',
        dueDate: dueDate,
        subtasks: subtasks,
      );

      final tasks = await fakeRepository.getTasks();
      expect(tasks.length, equals(1));

      final task = tasks.first;
      expect(task.title, equals('New Task'));
      expect(task.description, equals('New Description'));
      expect(task.categoryId, equals('cat-1'));
      expect(task.priority, equals(TaskPriority.high));
      expect(task.dueDate, equals(dueDate));
      expect(task.subtasks, equals(subtasks));
      expect(task.isCompleted, isFalse);
      expect(task.isArchived, isFalse);
      expect(task.isDeleted, isFalse);

      subscription.close();
    });

    test('toggleTaskCompletion should switch completion state', () async {
      final task = Task(
        id: '1',
        title: 'Task 1',
        isCompleted: false,
        createdAt: DateTime.now(),
      );
      await fakeRepository.saveTask(task);

      final subscription = container.listen(
        todoListControllerProvider,
        (previous, next) {},
      );
      final controller = container.read(todoListControllerProvider.notifier);

      await controller.toggleTaskCompletion('1');
      var updated = await fakeRepository.getTask('1');
      expect(updated?.isCompleted, isTrue);

      await controller.toggleTaskCompletion('1');
      updated = await fakeRepository.getTask('1');
      expect(updated?.isCompleted, isFalse);

      subscription.close();
    });

    test('toggleSubtaskCompletion should toggle specific subtask', () async {
      final task = Task(
        id: 'task-1',
        title: 'Task 1',
        subtasks: const [
          Subtask(id: 'sub-1', title: 'Sub 1', isCompleted: false),
          Subtask(id: 'sub-2', title: 'Sub 2', isCompleted: true),
        ],
        createdAt: DateTime.now(),
      );
      await fakeRepository.saveTask(task);

      final subscription = container.listen(
        todoListControllerProvider,
        (previous, next) {},
      );
      final controller = container.read(todoListControllerProvider.notifier);

      await controller.toggleSubtaskCompletion(
        taskId: 'task-1',
        subtaskId: 'sub-1',
      );
      var updated = await fakeRepository.getTask('task-1');
      expect(updated?.subtasks[0].isCompleted, isTrue);

      await controller.toggleSubtaskCompletion(
        taskId: 'task-1',
        subtaskId: 'sub-2',
      );
      updated = await fakeRepository.getTask('task-1');
      expect(updated?.subtasks[1].isCompleted, isFalse);

      subscription.close();
    });

    test(
      'archiveTask, softDeleteTask, restoreTask, deletePermanently',
      () async {
        final task = Task(id: '1', title: 'Task 1', createdAt: DateTime.now());
        await fakeRepository.saveTask(task);

        final subscription = container.listen(
          todoListControllerProvider,
          (previous, next) {},
        );
        final controller = container.read(todoListControllerProvider.notifier);

        // Archive
        await controller.archiveTask('1');
        var updated = await fakeRepository.getTask('1');
        expect(updated?.isArchived, isTrue);

        // Restore
        await controller.restoreTask('1');
        updated = await fakeRepository.getTask('1');
        expect(updated?.isArchived, isFalse);
        expect(updated?.isDeleted, isFalse);

        // Soft delete
        await controller.softDeleteTask('1');
        updated = await fakeRepository.getTask('1');
        expect(updated?.isDeleted, isTrue);

        // Delete permanently
        await controller.deletePermanently('1');
        updated = await fakeRepository.getTask('1');
        expect(updated, isNull);

        subscription.close();
      },
    );

    test('emptyTrash should remove all soft-deleted tasks', () async {
      final task1 = Task(
        id: '1',
        title: 'Task 1',
        isDeleted: true,
        createdAt: DateTime.now(),
      );
      final task2 = Task(
        id: '2',
        title: 'Task 2',
        isDeleted: false,
        createdAt: DateTime.now(),
      );
      await fakeRepository.saveTask(task1);
      await fakeRepository.saveTask(task2);

      final subscription = container.listen(
        todoListControllerProvider,
        (previous, next) {},
      );
      final controller = container.read(todoListControllerProvider.notifier);

      await controller.emptyTrash();
      expect(await fakeRepository.getTask('1'), isNull);
      expect(await fakeRepository.getTask('2'), isNotNull);

      subscription.close();
    });

    test('filtering and searching', () async {
      final now = DateTime.now();
      final task1 = Task(
        id: '1',
        title: 'Task Alpha',
        description: 'First task',
        categoryId: 'cat-1',
        priority: TaskPriority.high,
        createdAt: now,
      );
      final task2 = Task(
        id: '2',
        title: 'Task Beta',
        description: 'Second task',
        categoryId: 'cat-2',
        priority: TaskPriority.low,
        createdAt: now.add(const Duration(seconds: 1)),
      );
      await fakeRepository.saveTask(task1);
      await fakeRepository.saveTask(task2);

      final states = <List<Task>>[];
      final subscription = container.listen<AsyncValue<List<Task>>>(
        todoListControllerProvider,
        (previous, next) {
          next.whenData((value) => states.add(value));
        },
        fireImmediately: true,
      );

      final controller = container.read(todoListControllerProvider.notifier);

      await Future.delayed(Duration.zero);
      expect(states.last, equals([task1, task2]));

      // Test Search
      controller.setSearchQuery('Beta');
      await Future.delayed(Duration.zero);
      expect(states.last, equals([task2]));

      controller.setSearchQuery('Alpha');
      await Future.delayed(Duration.zero);
      expect(states.last, equals([task1]));

      controller.setSearchQuery('');
      await Future.delayed(Duration.zero);

      // Test Category Filter
      controller.setCategoryFilter('cat-2');
      await Future.delayed(Duration.zero);
      expect(states.last, equals([task2]));

      controller.setCategoryFilter(null);
      await Future.delayed(Duration.zero);

      // Test Priority Filter
      controller.setPriorityFilter(TaskPriority.high);
      await Future.delayed(Duration.zero);
      expect(states.last, equals([task1]));

      subscription.close();
    });

    test('sorting options', () async {
      final baseTime = DateTime(2026, 6, 1);
      final task1 = Task(
        id: '1',
        title: 'Task C',
        priority: TaskPriority.medium,
        dueDate: baseTime.add(const Duration(days: 3)),
        createdAt: baseTime,
      );
      final task2 = Task(
        id: '2',
        title: 'Task A',
        priority: TaskPriority.high,
        dueDate: baseTime.add(const Duration(days: 1)),
        createdAt: baseTime.add(const Duration(seconds: 1)),
      );
      final task3 = Task(
        id: '3',
        title: 'Task B',
        priority: TaskPriority.low,
        dueDate: null,
        createdAt: baseTime.add(const Duration(seconds: 2)),
      );

      await fakeRepository.saveTask(task1);
      await fakeRepository.saveTask(task2);
      await fakeRepository.saveTask(task3);

      final states = <List<Task>>[];
      final subscription = container.listen<AsyncValue<List<Task>>>(
        todoListControllerProvider,
        (previous, next) {
          next.whenData((value) => states.add(value));
        },
        fireImmediately: true,
      );

      final controller = container.read(todoListControllerProvider.notifier);

      // Default Sort: Due Date (task2 [1 day] -> task1 [3 days] -> task3 [null])
      await Future.delayed(Duration.zero);
      expect(states.last, equals([task2, task1, task3]));

      // Sort Alphabetical: A -> B -> C (task2, task3, task1)
      controller.setSortOption(TodoSortOption.alphabetical);
      await Future.delayed(Duration.zero);
      expect(states.last, equals([task2, task3, task1]));

      // Sort Priority: High -> Medium -> Low (task2, task1, task3)
      controller.setSortOption(TodoSortOption.priority);
      await Future.delayed(Duration.zero);
      expect(states.last, equals([task2, task1, task3]));

      subscription.close();
    });
  });
}
