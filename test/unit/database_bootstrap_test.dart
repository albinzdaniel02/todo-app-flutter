import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:todo_app/features/todo/data/models/category.dart';
import 'package:todo_app/features/todo/data/models/subtask.dart';
import 'package:todo_app/features/todo/data/models/task.dart';

void main() {
  group('Database Bootstrap Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('hive_test_dir');
      Hive.init(tempDir.path);
    });

    tearDown(() async {
      await Hive.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('should register adapters and open boxes successfully', () async {
      // Register type adapters
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(SubtaskModelAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(CategoryModelAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(TaskPriorityModelAdapter());
      }
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(TaskModelAdapter());
      }

      expect(Hive.isAdapterRegistered(1), isTrue); // Subtask
      expect(Hive.isAdapterRegistered(2), isTrue); // Category
      expect(Hive.isAdapterRegistered(3), isTrue); // TaskPriority
      expect(Hive.isAdapterRegistered(0), isTrue); // Task

      // Open boxes
      final tasksBox = await Hive.openBox<TaskModel>('tasks');
      final categoriesBox = await Hive.openBox<CategoryModel>('categories');

      expect(tasksBox.isOpen, isTrue);
      expect(categoriesBox.isOpen, isTrue);

      await tasksBox.close();
      await categoriesBox.close();
    });
  });
}
