import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:todo_app/features/todo/data/repositories/todo_repository_provider.dart';
import 'package:todo_app/features/todo/domain/entities/task.dart';
import 'package:todo_app/features/todo/domain/entities/subtask.dart';

part 'todo_list_controller.g.dart';

enum TodoStatusFilter { active, archived, trashed }

enum TodoSortOption { dueDate, priority, alphabetical }

@riverpod
class TodoSearchQuery extends _$TodoSearchQuery {
  @override
  String build() => '';

  void set(String query) => state = query;
}

@riverpod
class TodoCategoryFilter extends _$TodoCategoryFilter {
  @override
  String? build() => null;

  void set(String? categoryId) => state = categoryId;
}

@riverpod
class TodoPriorityFilter extends _$TodoPriorityFilter {
  @override
  TaskPriority? build() => null;

  void set(TaskPriority? priority) => state = priority;
}

@riverpod
class TodoStatusFilterState extends _$TodoStatusFilterState {
  @override
  TodoStatusFilter build() => TodoStatusFilter.active;

  void set(TodoStatusFilter filter) => state = filter;
}

@riverpod
class TodoSortOptionState extends _$TodoSortOptionState {
  @override
  TodoSortOption build() => TodoSortOption.dueDate;

  void set(TodoSortOption option) => state = option;
}

@riverpod
class TodoListController extends _$TodoListController {
  @override
  Stream<List<Task>> build() {
    final repository = ref.watch(todoRepositoryProvider);
    final searchQuery = ref.watch(todoSearchQueryProvider);
    final categoryFilter = ref.watch(todoCategoryFilterProvider);
    final priorityFilter = ref.watch(todoPriorityFilterProvider);
    final statusFilter = ref.watch(todoStatusFilterStateProvider);
    final sortOption = ref.watch(todoSortOptionStateProvider);

    Stream<List<Task>> taskStream;
    switch (statusFilter) {
      case TodoStatusFilter.active:
        taskStream = repository.watchActiveTasks();
        break;
      case TodoStatusFilter.archived:
        taskStream = repository.watchArchivedTasks();
        break;
      case TodoStatusFilter.trashed:
        taskStream = repository.watchTrashedTasks();
        break;
    }

    return taskStream.map((tasks) {
      final filtered = tasks.where((task) {
        if (searchQuery.isNotEmpty) {
          final query = searchQuery.toLowerCase();
          final titleMatch = task.title.toLowerCase().contains(query);
          final descMatch = task.description.toLowerCase().contains(query);
          if (!titleMatch && !descMatch) return false;
        }

        if (categoryFilter != null && task.categoryId != categoryFilter) {
          return false;
        }

        if (priorityFilter != null && task.priority != priorityFilter) {
          return false;
        }

        return true;
      }).toList();

      switch (sortOption) {
        case TodoSortOption.dueDate:
          filtered.sort((a, b) {
            if (a.dueDate == null && b.dueDate == null) {
              return a.createdAt.compareTo(b.createdAt);
            }
            if (a.dueDate == null) return 1;
            if (b.dueDate == null) return -1;
            return a.dueDate!.compareTo(b.dueDate!);
          });
          break;
        case TodoSortOption.priority:
          filtered.sort((a, b) {
            final cmp = b.priority.index.compareTo(a.priority.index);
            if (cmp != 0) return cmp;
            return a.createdAt.compareTo(b.createdAt);
          });
          break;
        case TodoSortOption.alphabetical:
          filtered.sort((a, b) {
            return a.title.toLowerCase().compareTo(b.title.toLowerCase());
          });
          break;
      }

      return filtered;
    });
  }

  // Filter and sorting actions exposed on controller
  void setSearchQuery(String query) {
    ref.read(todoSearchQueryProvider.notifier).set(query);
  }

  void setCategoryFilter(String? categoryId) {
    ref.read(todoCategoryFilterProvider.notifier).set(categoryId);
  }

  void setPriorityFilter(TaskPriority? priority) {
    ref.read(todoPriorityFilterProvider.notifier).set(priority);
  }

  void setStatusFilter(TodoStatusFilter filter) {
    ref.read(todoStatusFilterStateProvider.notifier).set(filter);
  }

  void setSortOption(TodoSortOption option) {
    ref.read(todoSortOptionStateProvider.notifier).set(option);
  }

  // CRUD & Task Actions
  Future<void> addTask({
    required String title,
    String? description,
    String? categoryId,
    String? priority,
    DateTime? dueDate,
    List<Subtask>? subtasks,
  }) async {
    final repository = ref.read(todoRepositoryProvider);
    final task = Task(
      id: const Uuid().v4(),
      title: title,
      description: description ?? '',
      categoryId: categoryId,
      priority: TaskPriority.fromString(priority),
      dueDate: dueDate,
      subtasks: subtasks ?? const [],
      createdAt: DateTime.now(),
    );
    await repository.saveTask(task);
  }

  Future<void> updateTask(Task task) async {
    final repository = ref.read(todoRepositoryProvider);
    await repository.saveTask(task);
  }

  Future<void> toggleTaskCompletion(String id) async {
    final repository = ref.read(todoRepositoryProvider);
    final task = await repository.getTask(id);
    if (task != null) {
      await repository.saveTask(task.copyWith(isCompleted: !task.isCompleted));
    }
  }

  Future<void> toggleSubtaskCompletion({
    required String taskId,
    required String subtaskId,
  }) async {
    final repository = ref.read(todoRepositoryProvider);
    final task = await repository.getTask(taskId);
    if (task != null) {
      final updatedSubtasks = task.subtasks.map((subtask) {
        if (subtask.id == subtaskId) {
          return subtask.copyWith(isCompleted: !subtask.isCompleted);
        }
        return subtask;
      }).toList();
      await repository.saveTask(task.copyWith(subtasks: updatedSubtasks));
    }
  }

  Future<void> archiveTask(String id) async {
    final repository = ref.read(todoRepositoryProvider);
    final task = await repository.getTask(id);
    if (task != null) {
      await repository.saveTask(task.copyWith(isArchived: true));
    }
  }

  Future<void> restoreTask(String id) async {
    final repository = ref.read(todoRepositoryProvider);
    final task = await repository.getTask(id);
    if (task != null) {
      await repository.saveTask(
        task.copyWith(isDeleted: false, isArchived: false),
      );
    }
  }

  Future<void> softDeleteTask(String id) async {
    final repository = ref.read(todoRepositoryProvider);
    final task = await repository.getTask(id);
    if (task != null) {
      await repository.saveTask(task.copyWith(isDeleted: true));
    }
  }

  Future<void> deletePermanently(String id) async {
    final repository = ref.read(todoRepositoryProvider);
    await repository.deleteTask(id);
  }

  Future<void> emptyTrash() async {
    final repository = ref.read(todoRepositoryProvider);
    final trashedTasks = await repository.getTrashedTasks();
    for (final task in trashedTasks) {
      await repository.deleteTask(task.id);
    }
  }
}
