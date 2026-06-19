import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:todo_app/features/todo/data/models/category.dart';
import 'package:todo_app/features/todo/data/models/subtask.dart';
import 'package:todo_app/features/todo/data/models/task.dart';

void main() {
  group('Database Persistence and Restart Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('hive_persistence_test');
    });

    tearDown(() async {
      await Hive.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    void registerAdapters() {
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
    }

    test(
      'Data correctly survives box closure and database re-initialization',
      () async {
        // 1. Initial boot and setup
        Hive.init(tempDir.path);
        registerAdapters();

        var categoriesBox = await Hive.openBox<CategoryModel>('categories');
        var tasksBox = await Hive.openBox<TaskModel>('tasks');

        // Create Category
        const testCategory = CategoryModel(
          id: 'cat-123',
          name: 'Work',
          colorHex: '#FF5733',
          iconCodePoint: 57432,
        );

        // Create Subtasks (one completed, one active)
        const subtask1 = SubtaskModel(
          id: 'sub-1',
          title: 'Draft proposal',
          isCompleted: true,
        );
        const subtask2 = SubtaskModel(
          id: 'sub-2',
          title: 'Review with team',
          isCompleted: false,
        );

        // Create Task referencing the category and subtasks
        final testTask = TaskModel(
          id: 'task-999',
          title: 'Launch Project Alpha',
          description: 'Complete the remaining phase deliverables',
          isCompleted: false,
          priority: TaskPriorityModel.high,
          dueDate: DateTime(2026, 7, 31),
          categoryId: 'cat-123',
          subtasks: const [subtask1, subtask2],
          isArchived: false,
          isDeleted: false,
          createdAt: DateTime(2026, 6, 19),
        );

        // Save to boxes
        await categoriesBox.put(testCategory.id, testCategory);
        await tasksBox.put(testTask.id, testTask);

        // Assert they are saved successfully
        expect(categoriesBox.get(testCategory.id), equals(testCategory));
        expect(tasksBox.get(testTask.id), equals(testTask));

        // 2. Simulate shutdown/restart by closing the boxes & Hive
        await tasksBox.close();
        await categoriesBox.close();
        await Hive.close();

        // 3. Re-initialize Hive using the same path and re-open boxes
        Hive.init(tempDir.path);
        registerAdapters();

        categoriesBox = await Hive.openBox<CategoryModel>('categories');
        tasksBox = await Hive.openBox<TaskModel>('tasks');

        // Verify boxes are open again
        expect(categoriesBox.isOpen, isTrue);
        expect(tasksBox.isOpen, isTrue);

        // 4. Retrieve saved data and verify fields match exactly
        final retrievedCategory = categoriesBox.get(testCategory.id);
        final retrievedTask = tasksBox.get(testTask.id);

        expect(retrievedCategory, isNotNull);
        expect(retrievedCategory!.id, equals('cat-123'));
        expect(retrievedCategory.name, equals('Work'));
        expect(retrievedCategory.colorHex, equals('#FF5733'));
        expect(retrievedCategory.iconCodePoint, equals(57432));

        expect(retrievedTask, isNotNull);
        expect(retrievedTask!.id, equals('task-999'));
        expect(retrievedTask.title, equals('Launch Project Alpha'));
        expect(
          retrievedTask.description,
          equals('Complete the remaining phase deliverables'),
        );
        expect(retrievedTask.isCompleted, isFalse);
        expect(retrievedTask.priority, equals(TaskPriorityModel.high));
        expect(retrievedTask.dueDate, equals(DateTime(2026, 7, 31)));
        expect(retrievedTask.categoryId, equals('cat-123'));
        expect(retrievedTask.isArchived, isFalse);
        expect(retrievedTask.isDeleted, isFalse);
        expect(retrievedTask.createdAt, equals(DateTime(2026, 6, 19)));

        // Verify subtasks length and completion states
        expect(retrievedTask.subtasks.length, equals(2));
        expect(retrievedTask.subtasks[0].id, equals('sub-1'));
        expect(retrievedTask.subtasks[0].title, equals('Draft proposal'));
        expect(retrievedTask.subtasks[0].isCompleted, isTrue);

        expect(retrievedTask.subtasks[1].id, equals('sub-2'));
        expect(retrievedTask.subtasks[1].title, equals('Review with team'));
        expect(retrievedTask.subtasks[1].isCompleted, isFalse);

        // Clean up
        await tasksBox.close();
        await categoriesBox.close();
      },
    );
  });
}
