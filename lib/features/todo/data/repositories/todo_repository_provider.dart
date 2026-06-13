import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_app/features/todo/data/models/task.dart';
import 'package:todo_app/features/todo/data/repositories/hive_todo_repository.dart';
import 'package:todo_app/features/todo/domain/repositories/todo_repository.dart';

part 'todo_repository_provider.g.dart';

@riverpod
TodoRepository todoRepository(TodoRepositoryRef ref) {
  final box = Hive.box<TaskModel>('tasks');
  return HiveTodoRepository(box);
}
