import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_app/features/category/data/repositories/hive_category_repository.dart';
import 'package:todo_app/features/category/domain/repositories/category_repository.dart';
import 'package:todo_app/features/todo/data/models/category.dart';

part 'category_repository_provider.g.dart';

@riverpod
CategoryRepository categoryRepository(CategoryRepositoryRef ref) {
  final box = Hive.box<CategoryModel>('categories');
  return HiveCategoryRepository(box);
}
