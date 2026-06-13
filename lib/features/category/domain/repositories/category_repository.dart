import 'package:todo_app/features/todo/data/models/category.dart';

abstract class CategoryRepository {
  /// Watches all categories in the database.
  Stream<List<Category>> watchCategories();

  /// Retrieves a list of all categories in the database.
  Future<List<Category>> getCategories();

  /// Retrieves a category by its unique ID.
  Future<Category?> getCategory(String id);

  /// Saves a category (creates if not existing, or updates if existing).
  Future<void> saveCategory(Category category);

  /// Deletes a category by its unique ID.
  Future<void> deleteCategory(String id);
}
