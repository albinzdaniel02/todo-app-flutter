import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/features/todo/data/models/task.dart';
import 'package:todo_app/features/todo/data/models/subtask.dart';
import 'package:todo_app/features/todo/domain/entities/task.dart' as domain;

import 'package:todo_app/features/todo/domain/entities/subtask.dart';

void main() {
  group('TaskModel Tests', () {
    const tId = 'e9b25fb3-96b6-4554-bc0f-c89b0d62dcf0';
    const tTitle = 'Buy groceries';
    const tDescription = 'Milk, eggs, and bread';
    const tIsCompleted = false;
    const tPriority = TaskPriorityModel.high;
    final tDueDate = DateTime.parse('2026-06-15T10:00:00.000Z');
    const tCategoryId = 'work-category-uuid';
    const tSubtasks = [
      SubtaskModel(
        id: '1f33f11d-2831-419b-ab0d-b8d9e2db3db1',
        title: 'Buy milk',
        isCompleted: true,
      ),
    ];
    const tIsArchived = false;
    const tIsDeleted = false;
    final tCreatedAt = DateTime.parse('2026-06-12T12:00:00.000Z');

    final tTask1 = TaskModel(
      id: tId,
      title: tTitle,
      description: tDescription,
      isCompleted: tIsCompleted,
      priority: tPriority,
      dueDate: tDueDate,
      categoryId: tCategoryId,
      subtasks: tSubtasks,
      isArchived: tIsArchived,
      isDeleted: tIsDeleted,
      createdAt: tCreatedAt,
    );

    final tTask2 = TaskModel(
      id: tId,
      title: tTitle,
      description: tDescription,
      isCompleted: tIsCompleted,
      priority: tPriority,
      dueDate: tDueDate,
      categoryId: tCategoryId,
      subtasks: tSubtasks,
      isArchived: tIsArchived,
      isDeleted: tIsDeleted,
      createdAt: tCreatedAt,
    );

    test('should support value equality', () {
      expect(tTask1, equals(tTask2));
    });

    test('copyWith should return a new object with updated values', () {
      final updated = tTask1.copyWith(
        isCompleted: true,
        priority: TaskPriorityModel.low,
        categoryId: null, // Test nullable categoryId override
        dueDate: null, // Test nullable dueDate override
      );

      expect(updated.id, tId);
      expect(updated.title, tTitle);
      expect(updated.isCompleted, true);
      expect(updated.priority, TaskPriorityModel.low);
      expect(updated.categoryId, isNull);
      expect(updated.dueDate, isNull);
    });

    test('fromJson should create a valid model from JSON', () {
      final Map<String, dynamic> jsonMap = {
        'id': tId,
        'title': tTitle,
        'description': tDescription,
        'isCompleted': tIsCompleted,
        'priority': 'high',
        'dueDate': '2026-06-15T10:00:00.000Z',
        'categoryId': tCategoryId,
        'subtasks': [
          {
            'id': '1f33f11d-2831-419b-ab0d-b8d9e2db3db1',
            'title': 'Buy milk',
            'isCompleted': true,
          },
        ],
        'isArchived': tIsArchived,
        'isDeleted': tIsDeleted,
        'createdAt': '2026-06-12T12:00:00.000Z',
      };

      final result = TaskModel.fromJson(jsonMap);

      expect(result, equals(tTask1));
    });

    test('toJson should return a JSON map containing correct data', () {
      final expectedMap = {
        'id': tId,
        'title': tTitle,
        'description': tDescription,
        'isCompleted': tIsCompleted,
        'priority': 'high',
        'dueDate': '2026-06-15T10:00:00.000Z',
        'categoryId': tCategoryId,
        'subtasks': [
          {
            'id': '1f33f11d-2831-419b-ab0d-b8d9e2db3db1',
            'title': 'Buy milk',
            'isCompleted': true,
          },
        ],
        'isArchived': tIsArchived,
        'isDeleted': tIsDeleted,
        'createdAt': '2026-06-12T12:00:00.000Z',
      };

      final result = tTask1.toJson();

      expect(result, expectedMap);
    });

    test('toDomain should convert to Task domain entity correctly', () {
      final domainTask = tTask1.toDomain();
      expect(domainTask.id, tId);
      expect(domainTask.title, tTitle);
      expect(domainTask.description, tDescription);
      expect(domainTask.isCompleted, tIsCompleted);
      expect(domainTask.priority, domain.TaskPriority.high);
      expect(domainTask.dueDate, tDueDate);
      expect(domainTask.categoryId, tCategoryId);
      expect(
        domainTask.subtasks.first.id,
        '1f33f11d-2831-419b-ab0d-b8d9e2db3db1',
      );
      expect(domainTask.isArchived, tIsArchived);
      expect(domainTask.isDeleted, tIsDeleted);
      expect(domainTask.createdAt, tCreatedAt);
    });

    test('fromDomain should convert from Task domain entity correctly', () {
      final domainTask = domain.Task(
        id: tId,
        title: tTitle,
        description: tDescription,
        isCompleted: tIsCompleted,
        priority: domain.TaskPriority.high,
        dueDate: tDueDate,
        categoryId: tCategoryId,
        subtasks: const [
          Subtask(
            id: '1f33f11d-2831-419b-ab0d-b8d9e2db3db1',
            title: 'Buy milk',
            isCompleted: true,
          ),
        ],
        isArchived: tIsArchived,
        isDeleted: tIsDeleted,
        createdAt: tCreatedAt,
      );

      final model = TaskModel.fromDomain(domainTask);

      expect(model, equals(tTask1));
    });
  });

  group('TaskPriorityModel Tests', () {
    test('fromString should parse priority string correctly', () {
      expect(
        TaskPriorityModel.fromString('low'),
        equals(TaskPriorityModel.low),
      );
      expect(
        TaskPriorityModel.fromString('medium'),
        equals(TaskPriorityModel.medium),
      );
      expect(
        TaskPriorityModel.fromString('high'),
        equals(TaskPriorityModel.high),
      );
      expect(
        TaskPriorityModel.fromString('HIGH'),
        equals(TaskPriorityModel.high),
      );
      expect(
        TaskPriorityModel.fromString(null),
        equals(TaskPriorityModel.medium),
      );
      expect(
        TaskPriorityModel.fromString('invalid'),
        equals(TaskPriorityModel.medium),
      );
    });

    test('toDomain should convert correctly', () {
      expect(TaskPriorityModel.low.toDomain(), equals(domain.TaskPriority.low));
      expect(
        TaskPriorityModel.medium.toDomain(),
        equals(domain.TaskPriority.medium),
      );
      expect(
        TaskPriorityModel.high.toDomain(),
        equals(domain.TaskPriority.high),
      );
    });

    test('fromDomain should convert correctly', () {
      expect(
        TaskPriorityModel.fromDomain(domain.TaskPriority.low),
        equals(TaskPriorityModel.low),
      );
      expect(
        TaskPriorityModel.fromDomain(domain.TaskPriority.medium),
        equals(TaskPriorityModel.medium),
      );
      expect(
        TaskPriorityModel.fromDomain(domain.TaskPriority.high),
        equals(TaskPriorityModel.high),
      );
    });
  });
}
