import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/features/todo/data/models/subtask.dart';

void main() {
  group('Subtask Model Tests', () {
    const tId = '1f33f11d-2831-419b-ab0d-b8d9e2db3db1';
    const tTitle = 'Buy milk';
    const tIsCompleted = true;

    test('should support value equality', () {
      const subtask1 = Subtask(
        id: tId,
        title: tTitle,
        isCompleted: tIsCompleted,
      );
      const subtask2 = Subtask(
        id: tId,
        title: tTitle,
        isCompleted: tIsCompleted,
      );
      expect(subtask1, equals(subtask2));
    });

    test('copyWith should return a new object with updated values', () {
      const subtask = Subtask(id: tId, title: tTitle, isCompleted: false);
      final updated = subtask.copyWith(isCompleted: true);

      expect(updated.id, tId);
      expect(updated.title, tTitle);
      expect(updated.isCompleted, true);
    });

    test('fromJson should create a valid model from JSON', () {
      final Map<String, dynamic> jsonMap = {
        'id': tId,
        'title': tTitle,
        'isCompleted': tIsCompleted,
      };

      final result = Subtask.fromJson(jsonMap);

      expect(
        result,
        const Subtask(id: tId, title: tTitle, isCompleted: tIsCompleted),
      );
    });

    test('toJson should return a JSON map containing correct data', () {
      const subtask = Subtask(
        id: tId,
        title: tTitle,
        isCompleted: tIsCompleted,
      );
      final expectedMap = {
        'id': tId,
        'title': tTitle,
        'isCompleted': tIsCompleted,
      };

      final result = subtask.toJson();

      expect(result, expectedMap);
    });
  });
}
