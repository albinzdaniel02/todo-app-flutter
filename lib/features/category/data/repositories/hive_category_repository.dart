import 'dart:async';
import 'package:hive/hive.dart';
import 'package:todo_app/features/category/domain/repositories/category_repository.dart';
import 'package:todo_app/features/todo/data/models/category.dart';

class HiveCategoryRepository implements CategoryRepository {
  final Box<Category> _box;

  HiveCategoryRepository(this._box);

  @override
  Stream<List<Category>> watchCategories() async* {
    yield _box.values.toList();
    yield* _box.watch().map((_) => _box.values.toList());
  }

  @override
  Future<List<Category>> getCategories() async {
    return _box.values.toList();
  }

  @override
  Future<Category?> getCategory(String id) async {
    return _box.get(id);
  }

  @override
  Future<void> saveCategory(Category category) async {
    await _box.put(category.id, category);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _box.delete(id);
  }
}
