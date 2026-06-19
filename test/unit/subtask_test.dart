import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/features/todo/data/models/subtask.dart';

import 'package:todo_app/features/todo/domain/entities/subtask.dart';

void main() {
  group('SubtaskModel Tests', () {
    const tId = '1f33f11d-2831-419b-ab0d-b8d9e2db3db1';
    const tTitle = 'Buy milk';
    const tIsCompleted = true;

    test('should support value equality', () {
      const subtask1 = SubtaskModel(
        id: tId,
        title: tTitle,
        isCompleted: tIsCompleted,
      );
      const subtask2 = SubtaskModel(
        id: tId,
        title: tTitle,
        isCompleted: tIsCompleted,
      );
      expect(subtask1, equals(subtask2));
    });

    test('copyWith should return a new object with updated values', () {
      const subtask = SubtaskModel(id: tId, title: tTitle, isCompleted: false);
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

      final result = SubtaskModel.fromJson(jsonMap);

      expect(
        result,
        const SubtaskModel(id: tId, title: tTitle, isCompleted: tIsCompleted),
      );
    });

    test('toJson should return a JSON map containing correct data', () {
      const subtask = SubtaskModel(
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

    test('toDomain should convert to Subtask domain entity correctly', () {
      const model = SubtaskModel(
        id: tId,
        title: tTitle,
        isCompleted: tIsCompleted,
      );
      final domain = model.toDomain();
      expect(domain.id, tId);
      expect(domain.title, tTitle);
      expect(domain.isCompleted, tIsCompleted);
    });

    test('fromDomain should convert from Subtask domain entity correctly', () {
      const domain = Subtask(id: tId, title: tTitle, isCompleted: tIsCompleted);
      final model = SubtaskModel.fromDomain(domain);
      expect(model.id, tId);
      expect(model.title, tTitle);
      expect(model.isCompleted, tIsCompleted);
    });
  });
}
