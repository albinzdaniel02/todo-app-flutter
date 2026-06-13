import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:todo_app/features/category/data/repositories/category_repository_provider.dart';
import 'package:todo_app/features/category/domain/entities/category.dart';

part 'category_list_controller.g.dart';

@riverpod
class CategoryListController extends _$CategoryListController {
  @override
  Stream<List<Category>> build() {
    final repository = ref.watch(categoryRepositoryProvider);
    return repository.watchCategories();
  }

  /// Adds a new category with a generated unique ID.
  Future<void> addCategory({
    required String name,
    required String colorHex,
    int? iconCodePoint,
  }) async {
    final repository = ref.read(categoryRepositoryProvider);
    final category = Category(
      id: const Uuid().v4(),
      name: name,
      colorHex: colorHex,
      iconCodePoint: iconCodePoint,
    );
    await repository.saveCategory(category);
  }

  /// Updates an existing category.
  Future<void> updateCategory(Category category) async {
    final repository = ref.read(categoryRepositoryProvider);
    await repository.saveCategory(category);
  }

  /// Deletes a category by its ID.
  Future<void> deleteCategory(String id) async {
    final repository = ref.read(categoryRepositoryProvider);
    await repository.deleteCategory(id);
  }
}
