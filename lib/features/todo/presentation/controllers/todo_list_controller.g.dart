// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$todoSearchQueryHash() => r'9c868e0611bbf503a980466a9c1aacb823fa612f';

/// See also [TodoSearchQuery].
@ProviderFor(TodoSearchQuery)
final todoSearchQueryProvider =
    AutoDisposeNotifierProvider<TodoSearchQuery, String>.internal(
      TodoSearchQuery.new,
      name: r'todoSearchQueryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$todoSearchQueryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TodoSearchQuery = AutoDisposeNotifier<String>;
String _$todoCategoryFilterHash() =>
    r'4aaa08d4eb7214f4852899052121270e62de1b7f';

/// See also [TodoCategoryFilter].
@ProviderFor(TodoCategoryFilter)
final todoCategoryFilterProvider =
    AutoDisposeNotifierProvider<TodoCategoryFilter, String?>.internal(
      TodoCategoryFilter.new,
      name: r'todoCategoryFilterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$todoCategoryFilterHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TodoCategoryFilter = AutoDisposeNotifier<String?>;
String _$todoPriorityFilterHash() =>
    r'8c9583759322af5ca903230e79e89772e7062179';

/// See also [TodoPriorityFilter].
@ProviderFor(TodoPriorityFilter)
final todoPriorityFilterProvider =
    AutoDisposeNotifierProvider<TodoPriorityFilter, TaskPriority?>.internal(
      TodoPriorityFilter.new,
      name: r'todoPriorityFilterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$todoPriorityFilterHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TodoPriorityFilter = AutoDisposeNotifier<TaskPriority?>;
String _$todoStatusFilterStateHash() =>
    r'ac75c72fe0d1a599cdd5f46bcbc5a015b1b60793';

/// See also [TodoStatusFilterState].
@ProviderFor(TodoStatusFilterState)
final todoStatusFilterStateProvider =
    AutoDisposeNotifierProvider<
      TodoStatusFilterState,
      TodoStatusFilter
    >.internal(
      TodoStatusFilterState.new,
      name: r'todoStatusFilterStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$todoStatusFilterStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TodoStatusFilterState = AutoDisposeNotifier<TodoStatusFilter>;
String _$todoSortOptionStateHash() =>
    r'5b452c69c129a81b93aa88eebffdfd0a0349392d';

/// See also [TodoSortOptionState].
@ProviderFor(TodoSortOptionState)
final todoSortOptionStateProvider =
    AutoDisposeNotifierProvider<TodoSortOptionState, TodoSortOption>.internal(
      TodoSortOptionState.new,
      name: r'todoSortOptionStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$todoSortOptionStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TodoSortOptionState = AutoDisposeNotifier<TodoSortOption>;
String _$todoListControllerHash() =>
    r'bfd93108c9061ed159cb2e4f07ebf0a42ec350d9';

/// See also [TodoListController].
@ProviderFor(TodoListController)
final todoListControllerProvider =
    AutoDisposeStreamNotifierProvider<TodoListController, List<Task>>.internal(
      TodoListController.new,
      name: r'todoListControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$todoListControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TodoListController = AutoDisposeStreamNotifier<List<Task>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
