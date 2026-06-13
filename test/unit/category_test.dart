import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/features/todo/data/models/category.dart';

void main() {
  group('Category Model Tests', () {
    const tId = '1f33f11d-2831-419b-ab0d-b8d9e2db3db1';
    const tName = 'Work';
    const tColorHex = '#FF42A5F5';
    const tIconCodePoint = 50123;

    test('should support value equality', () {
      const category1 = Category(
        id: tId,
        name: tName,
        colorHex: tColorHex,
        iconCodePoint: tIconCodePoint,
      );
      const category2 = Category(
        id: tId,
        name: tName,
        colorHex: tColorHex,
        iconCodePoint: tIconCodePoint,
      );
      expect(category1, equals(category2));
    });

    test('copyWith should return a new object with updated values', () {
      const category = Category(
        id: tId,
        name: tName,
        colorHex: tColorHex,
        iconCodePoint: tIconCodePoint,
      );
      final updated = category.copyWith(name: 'Shopping', iconCodePoint: null);

      expect(updated.id, tId);
      expect(updated.name, 'Shopping');
      expect(updated.colorHex, tColorHex);
      expect(updated.iconCodePoint, isNull);
    });

    test('fromJson should create a valid model from JSON', () {
      final Map<String, dynamic> jsonMap = {
        'id': tId,
        'name': tName,
        'colorHex': tColorHex,
        'iconCodePoint': tIconCodePoint,
      };

      final result = Category.fromJson(jsonMap);

      expect(
        result,
        const Category(
          id: tId,
          name: tName,
          colorHex: tColorHex,
          iconCodePoint: tIconCodePoint,
        ),
      );
    });

    test('toJson should return a JSON map containing correct data', () {
      const category = Category(
        id: tId,
        name: tName,
        colorHex: tColorHex,
        iconCodePoint: tIconCodePoint,
      );
      final expectedMap = {
        'id': tId,
        'name': tName,
        'colorHex': tColorHex,
        'iconCodePoint': tIconCodePoint,
      };

      final result = category.toJson();

      expect(result, expectedMap);
    });
  });
}
