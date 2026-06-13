import 'dart:async';
import 'package:hive/hive.dart';
import 'package:todo_app/features/category/domain/entities/category.dart';
import 'package:todo_app/features/category/domain/repositories/category_repository.dart';
import 'package:todo_app/features/todo/data/models/category.dart';

class HiveCategoryRepository implements CategoryRepository {
  final Box<CategoryModel> _box;

  HiveCategoryRepository(this._box);

  @override
  Stream<List<Category>> watchCategories() async* {
    yield _box.values.map((e) => e.toDomain()).toList();
    yield* _box.watch().map(
      (_) => _box.values.map((e) => e.toDomain()).toList(),
    );
  }

  @override
  Future<List<Category>> getCategories() async {
    return _box.values.map((e) => e.toDomain()).toList();
  }

  @override
  Future<Category?> getCategory(String id) async {
    final model = _box.get(id);
    return model?.toDomain();
  }

  @override
  Future<void> saveCategory(Category category) async {
    await _box.put(category.id, CategoryModel.fromDomain(category));
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _box.delete(id);
  }
}
