import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/features/category/data/repositories/category_repository_provider.dart';
import 'package:todo_app/features/category/domain/entities/category.dart';
import 'package:todo_app/features/category/domain/repositories/category_repository.dart';
import 'package:todo_app/features/category/presentation/controllers/category_list_controller.dart';

class FakeCategoryRepository implements CategoryRepository {
  final List<Category> _categories = [];
  final StreamController<List<Category>> _controller =
      StreamController<List<Category>>.broadcast();

  @override
  Stream<List<Category>> watchCategories() async* {
    yield List.unmodifiable(_categories);
    yield* _controller.stream;
  }

  @override
  Future<List<Category>> getCategories() async => List.unmodifiable(_categories);

  @override
  Future<Category?> getCategory(String id) async {
    try {
      return _categories.firstWhere((element) => element.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveCategory(Category category) async {
    final index = _categories.indexWhere((element) => element.id == category.id);
    if (index >= 0) {
      _categories[index] = category;
    } else {
      _categories.add(category);
    }
    _controller.add(List.unmodifiable(_categories));
  }

  @override
  Future<void> deleteCategory(String id) async {
    _categories.removeWhere((element) => element.id == id);
    _controller.add(List.unmodifiable(_categories));
  }

  void dispose() {
    _controller.close();
  }
}

void main() {
  group('CategoryListController Tests', () {
    late FakeCategoryRepository fakeRepository;
    late ProviderContainer container;

    setUp(() {
      fakeRepository = FakeCategoryRepository();
      container = ProviderContainer(
        overrides: [
          categoryRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
      fakeRepository.dispose();
    });

    test('build should watch categories stream', () async {
      final states = <List<Category>>[];
      final subscription = container.listen<AsyncValue<List<Category>>>(
        categoryListControllerProvider,
        (previous, next) {
          next.whenData((value) => states.add(value));
        },
        fireImmediately: true,
      );

      // Wait for stream to emit initial value
      await Future.delayed(Duration.zero);
      expect(states, [isEmpty]);

      const category = Category(id: '1', name: 'Work', colorHex: '#FF0000');
      await fakeRepository.saveCategory(category);

      // Wait for stream event to propagate
      await Future.delayed(Duration.zero);
      expect(states, [isEmpty, equals([category])]);

      subscription.close();
    });

    test('addCategory should save category through repository', () async {
      final controller = container.read(categoryListControllerProvider.notifier);

      await controller.addCategory(
        name: 'Study',
        colorHex: '#00FF00',
        iconCodePoint: 123,
      );

      final categories = await fakeRepository.getCategories();
      expect(categories.length, equals(1));
      expect(categories.first.name, equals('Study'));
      expect(categories.first.colorHex, equals('#00FF00'));
      expect(categories.first.iconCodePoint, equals(123));
      expect(categories.first.id, isNotEmpty);
    });

    test('updateCategory should modify existing category', () async {
      const category = Category(id: '1', name: 'Work', colorHex: '#FF0000');
      await fakeRepository.saveCategory(category);

      final controller = container.read(categoryListControllerProvider.notifier);
      final updatedCategory = category.copyWith(name: 'Work Updated');
      await controller.updateCategory(updatedCategory);

      final categories = await fakeRepository.getCategories();
      expect(categories.first.name, equals('Work Updated'));
    });

    test('deleteCategory should delete category', () async {
      const category = Category(id: '1', name: 'Work', colorHex: '#FF0000');
      await fakeRepository.saveCategory(category);

      final controller = container.read(categoryListControllerProvider.notifier);
      await controller.deleteCategory('1');

      final categories = await fakeRepository.getCategories();
      expect(categories, isEmpty);
    });
  });
}
