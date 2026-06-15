import 'dart:async';
import 'package:todo_app/features/category/domain/entities/category.dart';
import 'package:todo_app/features/category/domain/repositories/category_repository.dart';
import 'package:todo_app/features/todo/domain/entities/task.dart';
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
