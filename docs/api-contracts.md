# API & Layer Contracts: Flutter Todo App

Since this app is offline-first, the "API Contracts" represent the boundaries, abstract interfaces, and serialization formats between the different layers of the app (Data, Domain, Presentation, and System Services).

---

## 1. Domain Repository Contracts

These abstract contracts define how the presentation layer or use cases interact with the data storage layer.

### 1.1 TodoRepository Contract
Located at `lib/features/todo/domain/repositories/todo_repository.dart`

```dart
abstract class TodoRepository {
  /// Stream of all tasks for reactive UI updates
  Stream<List<Task>> watchTasks();

  /// Retrieve a specific task by ID
  Future<Task?> getTaskById(String id);

  /// Fetch all active (non-archived, non-deleted) tasks
  Future<List<Task>> getActiveTasks();

  /// Fetch all archived tasks
  Future<List<Task>> getArchivedTasks();

  /// Fetch all soft-deleted tasks
  Future<List<Task>> getDeletedTasks();

  /// Save or update a task in storage
  Future<void> saveTask(Task task);

  /// Delete a task from storage permanently
  Future<void> deleteTask(String id);

  /// Clear all soft-deleted tasks permanently (Empty Trash)
  Future<void> clearTrash();
}
```

### 1.2 CategoryRepository Contract
Located at `lib/features/category/domain/repositories/category_repository.dart`

```dart
abstract class CategoryRepository {
  /// Stream of all custom categories
  Stream<List<Category>> watchCategories();

  /// Fetch all custom categories
  Future<List<Category>> getCategories();

  /// Save or update a category
  Future<void> saveCategory(Category category);

  /// Delete a category from storage
  Future<void> deleteCategory(String id);
}
```

---

## 2. Infrastructure Service Contracts

Contracts defining boundaries between the Dart code and platform-native systems.

### 2.1 NotificationService Contract
Located at `lib/core/services/notification_service.dart`

```dart
abstract class NotificationService {
  /// Request permissions and initialize notification channel channels
  Future<bool> initialize();

  /// Schedule a notification for a task at a specific time
  Future<void> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  });

  /// Cancel a scheduled notification
  Future<void> cancelNotification(String id);

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications();
}
```

---

## 3. UI State Controller Contracts (Riverpod)

These signatures outline the public methods exposed by Riverpod Controllers (`Notifier` or `AsyncNotifier`) to UI widgets.

### 3.1 TodoListController Actions
Located at `lib/features/todo/presentation/controllers/todo_list_controller.dart`

```dart
class TodoListController extends _$TodoListController {
  @override
  FutureOr<List<Task>> build() async { ... }

  Future<void> addTask({
    required String title,
    String? description,
    String? categoryId,
    String? priority,
    DateTime? dueDate,
    List<Subtask>? subtasks,
  });

  Future<void> updateTask(Task task);
  
  Future<void> toggleTaskCompletion(String id);

  Future<void> toggleSubtaskCompletion({required String taskId, required String subtaskId});

  Future<void> archiveTask(String id);

  Future<void> restoreTask(String id);

  Future<void> softDeleteTask(String id);

  Future<void> deletePermanently(String id);
  
  Future<void> emptyTrash();
}
```

---

## 4. Import / Export Data Formats (JSON Contracts)

To allow users to backup or move their data, the local databases can be serialized to JSON.

### 4.1 Task JSON Payload
```json
{
  "id": "e9b25fb3-96b6-4554-bc0f-c89b0d62dcf0",
  "title": "Buy groceries",
  "description": "Milk, eggs, and bread",
  "isCompleted": false,
  "priority": "high",
  "dueDate": "2026-06-15T10:00:00.000Z",
  "categoryId": "work-category-uuid",
  "subtasks": [
    {
      "id": "1f33f11d-2831-419b-ab0d-b8d9e2db3db1",
      "title": "Buy milk",
      "isCompleted": true
    }
  ],
  "isArchived": false,
  "isDeleted": false,
  "createdAt": "2026-06-12T12:00:00.000Z"
}
```

### 4.2 Category JSON Payload
```json
{
  "id": "work-category-uuid",
  "name": "Work",
  "colorHex": "FF42A5F5",
  "iconCodePoint": 58263
}
```
