import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:todo_app/features/category/data/repositories/hive_category_repository.dart';
import 'package:todo_app/features/todo/data/models/category.dart';

void main() {
  group('HiveCategoryRepository Tests', () {
    late Directory tempDir;
    late Box<Category> categoriesBox;
    late HiveCategoryRepository repository;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'hive_category_repo_test',
      );
      Hive.init(tempDir.path);

      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(CategoryAdapter());
      }

      categoriesBox = await Hive.openBox<Category>('categories');
      repository = HiveCategoryRepository(categoriesBox);
    });

    tearDown(() async {
      await categoriesBox.close();
      await Hive.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    const tCategory = Category(
      id: 'cat-1',
      name: 'Work',
      colorHex: '#FF00FF',
      iconCodePoint: 1234,
    );

    test('getCategories should return empty list initially', () async {
      final categories = await repository.getCategories();
      expect(categories, isEmpty);
    });

    test(
      'saveCategory should add category to box and getCategory should retrieve it',
      () async {
        await repository.saveCategory(tCategory);

        final retrieved = await repository.getCategory(tCategory.id);
        expect(retrieved, equals(tCategory));

        final categories = await repository.getCategories();
        expect(categories, contains(tCategory));
      },
    );

    test('deleteCategory should remove category from box', () async {
      await repository.saveCategory(tCategory);
      await repository.deleteCategory(tCategory.id);

      final retrieved = await repository.getCategory(tCategory.id);
      expect(retrieved, isNull);

      final categories = await repository.getCategories();
      expect(categories, isEmpty);
    });

    test('watchCategories should emit updated category lists', () async {
      final emissions = <List<Category>>[];

      final subscription = repository.watchCategories().listen((list) {
        emissions.add(list);
      });

      await Future.delayed(Duration.zero);

      await repository.saveCategory(tCategory);
      await Future.delayed(Duration.zero);

      await repository.deleteCategory(tCategory.id);
      await Future.delayed(Duration.zero);

      await subscription.cancel();

      expect(emissions.length, equals(3));
      expect(emissions[0], isEmpty);
      expect(emissions[1], equals([tCategory]));
      expect(emissions[2], isEmpty);
    });
  });
}
