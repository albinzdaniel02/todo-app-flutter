import 'package:todo_app/features/todo/domain/entities/task.dart';

abstract class TodoRepository {
  /// Watches all tasks in the database.
  Stream<List<Task>> watchTasks();

  /// Watches only active tasks (i.e. isArchived == false && isDeleted == false).
  Stream<List<Task>> watchActiveTasks();

  /// Watches archived tasks (i.e. isArchived == true && isDeleted == false).
  Stream<List<Task>> watchArchivedTasks();

  /// Watches trashed tasks (i.e. isDeleted == true).
  Stream<List<Task>> watchTrashedTasks();

  /// Retrieves all tasks in the database.
  Future<List<Task>> getTasks();

  /// Retrieves only active tasks.
  Future<List<Task>> getActiveTasks();

  /// Retrieves archived tasks.
  Future<List<Task>> getArchivedTasks();

  /// Retrieves trashed tasks.
  Future<List<Task>> getTrashedTasks();

  /// Retrieves a task by its unique ID.
  Future<Task?> getTask(String id);

  /// Saves a task (creates if not existing, or updates if existing).
  Future<void> saveTask(Task task);

  /// Permanently deletes a task by its unique ID.
  Future<void> deleteTask(String id);
}
