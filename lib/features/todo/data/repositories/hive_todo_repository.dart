import 'dart:async';
import 'package:hive/hive.dart';
import 'package:todo_app/features/todo/data/models/task.dart';
import 'package:todo_app/features/todo/domain/entities/task.dart';
import 'package:todo_app/features/todo/domain/repositories/todo_repository.dart';

class HiveTodoRepository implements TodoRepository {
  final Box<TaskModel> _box;

  HiveTodoRepository(this._box);

  @override
  Stream<List<Task>> watchTasks() async* {
    yield _box.values.map((e) => e.toDomain()).toList();
    yield* _box.watch().map(
      (_) => _box.values.map((e) => e.toDomain()).toList(),
    );
  }

  @override
  Stream<List<Task>> watchActiveTasks() async* {
    yield _box.values
        .where((e) => !e.isArchived && !e.isDeleted)
        .map((e) => e.toDomain())
        .toList();
    yield* _box.watch().map(
      (_) => _box.values
          .where((e) => !e.isArchived && !e.isDeleted)
          .map((e) => e.toDomain())
          .toList(),
    );
  }

  @override
  Stream<List<Task>> watchArchivedTasks() async* {
    yield _box.values
        .where((e) => e.isArchived && !e.isDeleted)
        .map((e) => e.toDomain())
        .toList();
    yield* _box.watch().map(
      (_) => _box.values
          .where((e) => e.isArchived && !e.isDeleted)
          .map((e) => e.toDomain())
          .toList(),
    );
  }

  @override
  Stream<List<Task>> watchTrashedTasks() async* {
    yield _box.values
        .where((e) => e.isDeleted)
        .map((e) => e.toDomain())
        .toList();
    yield* _box.watch().map(
      (_) => _box.values
          .where((e) => e.isDeleted)
          .map((e) => e.toDomain())
          .toList(),
    );
  }

  @override
  Future<List<Task>> getTasks() async {
    return _box.values.map((e) => e.toDomain()).toList();
  }

  @override
  Future<List<Task>> getActiveTasks() async {
    return _box.values
        .where((e) => !e.isArchived && !e.isDeleted)
        .map((e) => e.toDomain())
        .toList();
  }

  @override
  Future<List<Task>> getArchivedTasks() async {
    return _box.values
        .where((e) => e.isArchived && !e.isDeleted)
        .map((e) => e.toDomain())
        .toList();
  }

  @override
  Future<List<Task>> getTrashedTasks() async {
    return _box.values
        .where((e) => e.isDeleted)
        .map((e) => e.toDomain())
        .toList();
  }

  @override
  Future<Task?> getTask(String id) async {
    final model = _box.get(id);
    return model?.toDomain();
  }

  @override
  Future<void> saveTask(Task task) async {
    await _box.put(task.id, TaskModel.fromDomain(task));
  }

  @override
  Future<void> deleteTask(String id) async {
    await _box.delete(id);
  }
}
