import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/features/category/data/repositories/category_repository_provider.dart';
import 'package:todo_app/features/category/domain/entities/category.dart';
import 'package:todo_app/features/category/domain/repositories/category_repository.dart';
import 'package:todo_app/features/todo/data/repositories/todo_repository_provider.dart';
import 'package:todo_app/features/todo/domain/entities/task.dart';
import 'package:todo_app/features/todo/domain/repositories/todo_repository.dart';
import 'package:todo_app/main.dart';

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

class FakeCategoryRepository implements CategoryRepository {
  final List<Category> _categories = [];
  final StreamController<List<Category>> _controller =
      StreamController<List<Category>>.broadcast();

  @override
  Stream<List<Category>> watchCategories() async* {
    yield List.unmodifiable(_categories);
    yield* _controller.stream;
  }

  @override
  Future<List<Category>> getCategories() async =>
      List.unmodifiable(_categories);

  @override
  Future<Category?> getCategory(String id) async {
    for (final category in _categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  @override
  Future<void> saveCategory(Category category) async {
    final index = _categories.indexWhere(
      (element) => element.id == category.id,
    );
    if (index >= 0) {
      _categories[index] = category;
    } else {
      _categories.add(category);
    }
    _controller.add(List.unmodifiable(_categories));
  }

  @override
  Future<void> deleteCategory(String id) async {
    _categories.removeWhere((element) => element.id == id);
    _controller.add(List.unmodifiable(_categories));
  }

  void dispose() {
    _controller.close();
  }
}

void main() {
  late FakeTodoRepository fakeTodoRepository;
  late FakeCategoryRepository fakeCategoryRepository;

  setUp(() {
    fakeTodoRepository = FakeTodoRepository();
    fakeCategoryRepository = FakeCategoryRepository();
  });

  tearDown(() {
    fakeTodoRepository.dispose();
    fakeCategoryRepository.dispose();
  });

  testWidgets('Swipe right to toggle completion status', (
    WidgetTester tester,
  ) async {
    // 1. Seed repository with an incomplete task
    final task = Task(
      id: 'task-1',
      title: 'Swipe Right Task',
      isCompleted: false,
      createdAt: DateTime.now(),
    );
    await fakeTodoRepository.saveTask(task);

    // 2. Build the app with overrides
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todoRepositoryProvider.overrideWithValue(fakeTodoRepository),
          categoryRepositoryProvider.overrideWithValue(fakeCategoryRepository),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify task is initially displayed and not completed
    expect(find.text('Swipe Right Task'), findsOneWidget);
    final checkboxFinder = find.byType(Checkbox);
    expect(tester.widget<Checkbox>(checkboxFinder).value, isFalse);

    // 3. Swipe the task card to the right (start to end)
    final taskCard = find.text('Swipe Right Task');
    await tester.drag(taskCard, const Offset(500.0, 0.0));
    await tester.pumpAndSettle();

    // Verify task status in database was updated
    final updatedTask = await fakeTodoRepository.getTask('task-1');
    expect(updatedTask?.isCompleted, isTrue);

    // Verify UI updated
    expect(tester.widget<Checkbox>(checkboxFinder).value, isTrue);
  });

  testWidgets('Swipe left to soft-delete task', (WidgetTester tester) async {
    // 1. Seed repository with an active task
    final task = Task(
      id: 'task-2',
      title: 'Swipe Left Task',
      isCompleted: false,
      createdAt: DateTime.now(),
    );
    await fakeTodoRepository.saveTask(task);

    // 2. Build the app with overrides
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todoRepositoryProvider.overrideWithValue(fakeTodoRepository),
          categoryRepositoryProvider.overrideWithValue(fakeCategoryRepository),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify task is displayed
    expect(find.text('Swipe Left Task'), findsOneWidget);

    // 3. Swipe the task card to the left (end to start)
    final taskCard = find.text('Swipe Left Task');
    await tester.drag(taskCard, const Offset(-500.0, 0.0));
    await tester.pumpAndSettle();

    // Verify task is removed from active tasks list in DB (isDeleted = true)
    final updatedTask = await fakeTodoRepository.getTask('task-2');
    expect(updatedTask?.isDeleted, isTrue);

    // Verify UI has updated and card is gone
    expect(find.text('Swipe Left Task'), findsNothing);

    // Verify undo snackbar is shown
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('"Swipe Left Task" moved to trash'), findsOneWidget);

    // 4. Tap 'Undo' and verify task is restored
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    final restoredTask = await fakeTodoRepository.getTask('task-2');
    expect(restoredTask?.isDeleted, isFalse);

    // Verify task is back in the UI
    expect(find.text('Swipe Left Task'), findsOneWidget);
  });
}
