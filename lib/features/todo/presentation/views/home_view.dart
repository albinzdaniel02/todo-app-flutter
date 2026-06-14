import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/core/theme/theme_controller.dart';
import 'package:todo_app/features/category/domain/entities/category.dart';
import 'package:todo_app/features/category/presentation/controllers/category_list_controller.dart';
import 'package:todo_app/features/category/presentation/views/category_color_picker.dart';
import 'package:todo_app/features/category/presentation/views/edit_category_dialog.dart';
import 'package:todo_app/features/todo/domain/entities/task.dart';
import 'package:todo_app/features/todo/presentation/controllers/navigation_controller.dart';
import 'package:todo_app/features/todo/presentation/controllers/todo_list_controller.dart';
import 'package:todo_app/features/todo/presentation/views/add_task_bottom_sheet.dart';
import 'package:todo_app/features/todo/presentation/views/archive_view.dart';
import 'package:todo_app/features/todo/presentation/views/trash_view.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationControllerProvider);
    final titles = const ['My Tasks', 'Tags', 'Settings'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[currentIndex]),
        elevation: 0,
        actions: currentIndex == 0
            ? [
                PopupMenuButton<String>(
                  key: const Key('homeMenuButton'),
                  onSelected: (value) {
                    if (value == 'archive') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ArchiveView(),
                        ),
                      );
                    } else if (value == 'trash') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TrashView(),
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'archive',
                      child: Row(
                        children: [
                          Icon(Icons.archive_outlined),
                          SizedBox(width: 8),
                          Text('Archive'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'trash',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline),
                          SizedBox(width: 8),
                          Text('Trash'),
                        ],
                      ),
                    ),
                  ],
                ),
              ]
            : null,
      ),
      body: IndexedStack(
        index: currentIndex,
        children: const [TodoTab(), TagsTab(), SettingsTab()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(navigationControllerProvider.notifier).setIndex(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box_outlined),
            activeIcon: Icon(Icons.check_box),
            label: 'Todo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.label_outline),
            activeIcon: Icon(Icons.label),
            label: 'Tags',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => _showAddTaskBottomSheet(context),
              tooltip: 'Add Task',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showAddTaskBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTaskBottomSheet(),
    );
  }
}

class TodoTab extends ConsumerStatefulWidget {
  const TodoTab({super.key});

  @override
  ConsumerState<TodoTab> createState() => _TodoTabState();
}

class _TodoTabState extends ConsumerState<TodoTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(todoListControllerProvider);
    final categoriesAsync = ref.watch(categoryListControllerProvider);
    final selectedCategoryId = ref.watch(todoCategoryFilterProvider);

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search Tasks...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref
                            .read(todoListControllerProvider.notifier)
                            .setSearchQuery('');
                        setState(() {});
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withAlpha(80),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withAlpha(80),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: (value) {
              ref
                  .read(todoListControllerProvider.notifier)
                  .setSearchQuery(value);
              setState(() {});
            },
          ),
        ),

        // Category Filter Chips
        categoriesAsync.when(
          data: (categories) {
            return SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: selectedCategoryId == null,
                    onSelected: (selected) {
                      if (selected) {
                        ref
                            .read(todoListControllerProvider.notifier)
                            .setCategoryFilter(null);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ...categories.map((category) {
                    final color = _parseHexColor(category.colorHex);
                    final isSelected = selectedCategoryId == category.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category.name),
                        selected: isSelected,
                        selectedColor: color.withAlpha(50),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? color
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          ref
                              .read(todoListControllerProvider.notifier)
                              .setCategoryFilter(selected ? category.id : null);
                        },
                      ),
                    );
                  }),
                ],
              ),
            );
          },
          loading: () => const SizedBox(
            height: 48,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (err, stack) => const SizedBox.shrink(),
        ),

        // Task List
        Expanded(
          child: tasksAsync.when(
            data: (tasks) {
              if (tasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_turned_in_outlined,
                        size: 64,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(80),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tasks found',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withAlpha(150),
                            ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  // Resolve category name and color
                  Category? taskCategory;
                  categoriesAsync.whenData((categories) {
                    try {
                      taskCategory = categories.firstWhere(
                        (cat) => cat.id == task.categoryId,
                      );
                    } catch (_) {
                      taskCategory = null;
                    }
                  });

                  return Dismissible(
                    key: Key('task_${task.id}'),
                    background: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade600,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.check, color: Colors.white),
                    ),
                    secondaryBackground: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        await ref
                            .read(todoListControllerProvider.notifier)
                            .toggleTaskCompletion(task.id);
                        return false;
                      }
                      return true;
                    },
                    onDismissed: (direction) {
                      if (direction == DismissDirection.endToStart) {
                        ref
                            .read(todoListControllerProvider.notifier)
                            .softDeleteTask(task.id);

                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('"${task.title}" moved to trash'),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {
                                ref
                                    .read(todoListControllerProvider.notifier)
                                    .restoreTask(task.id);
                              },
                            ),
                          ),
                        );
                      }
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withAlpha(40),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: task.isCompleted,
                                  onChanged: (_) {
                                    ref
                                        .read(
                                          todoListControllerProvider.notifier,
                                        )
                                        .toggleTaskCompletion(task.id);
                                  },
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          task.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                decoration: task.isCompleted
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                                color: task.isCompleted
                                                    ? Theme.of(context)
                                                          .colorScheme
                                                          .onSurface
                                                          .withAlpha(120)
                                                    : null,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        if (task.description.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            task.description,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Badges Row
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                // Priority Badge
                                _Badge(
                                  label: task.priority.name.toUpperCase(),
                                  color: _getPriorityColor(task.priority),
                                ),

                                // Category Badge
                                if (taskCategory != null)
                                  _Badge(
                                    label: taskCategory!.name,
                                    color: _parseHexColor(
                                      taskCategory!.colorHex,
                                    ),
                                  ),

                                // Due Date Badge
                                if (task.dueDate != null)
                                  _Badge(
                                    label: _formatDateTime(task.dueDate!),
                                    color: Colors.blue.shade600,
                                    icon: Icons.calendar_today,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error loading tasks: $err')),
          ),
        ),
      ],
    );
  }
}

class TagsTab extends ConsumerStatefulWidget {
  const TagsTab({super.key});

  @override
  ConsumerState<TagsTab> createState() => _TagsTabState();
}

class _TagsTabState extends ConsumerState<TagsTab> {
  final TextEditingController _categoryNameController = TextEditingController();
  Color _selectedColor = Colors.indigo;

  @override
  void dispose() {
    _categoryNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListControllerProvider);

    return categoriesAsync.when(
      data: (categories) {
        return ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Create Tag',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        key: const Key('createTagNameField'),
                        controller: _categoryNameController,
                        decoration: const InputDecoration(
                          hintText: 'Tag Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tag Color',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CategoryColorPicker(
                        initialColor: _selectedColor,
                        onColorChanged: (color) {
                          _selectedColor = color;
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        key: const Key('addTagButton'),
                        onPressed: () async {
                          final name = _categoryNameController.text.trim();
                          if (name.isNotEmpty) {
                            final colorHex =
                                '#${_selectedColor.toARGB32().toRadixString(16).substring(2)}';
                            await ref
                                .read(categoryListControllerProvider.notifier)
                                .addCategory(name: name, colorHex: colorHex);
                            _categoryNameController.clear();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Tag "$name" created!')),
                              );
                            }
                          }
                        },
                        child: const Text('Add Tag'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (categories.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'No tags created yet.',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(120),
                    ),
                  ),
                ),
              )
            else
              ...categories.map((category) {
                final color = _parseHexColor(category.colorHex);
                return ListTile(
                  leading: CircleAvatar(backgroundColor: color, radius: 12),
                  title: Text(category.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        key: Key('edit_category_${category.id}'),
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                EditCategoryDialog(category: category),
                          );
                        },
                      ),
                      IconButton(
                        key: Key('delete_category_${category.id}'),
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          ref
                              .read(categoryListControllerProvider.notifier)
                              .deleteCategory(category.id);
                        },
                      ),
                    ],
                  ),
                );
              }),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error loading tags: $err')),
    );
  }
}

class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Column(
            children: [
              ListTile(
                title: const Text('Theme Mode'),
                subtitle: Text(_themeModeName(themeMode)),
                trailing: PopupMenuButton<ThemeMode>(
                  initialValue: themeMode,
                  onSelected: (mode) {
                    ref
                        .read(themeControllerProvider.notifier)
                        .setThemeMode(mode);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: ThemeMode.system,
                      child: Text('System Default'),
                    ),
                    const PopupMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light Mode'),
                    ),
                    const PopupMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark Mode'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                key: const Key('settingsArchiveTile'),
                leading: const Icon(Icons.archive_outlined),
                title: const Text('Archived Tasks'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ArchiveView(),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                key: const Key('settingsTrashTile'),
                leading: const Icon(Icons.delete_outline),
                title: const Text('Trash'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TrashView()),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _themeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.dark:
        return 'Dark Mode';
    }
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _Badge({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

Color _parseHexColor(String hexString) {
  try {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) {
      buffer.write('ff');
    }
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  } catch (_) {
    return Colors.grey;
  }
}

String _formatDateTime(DateTime dateTime) {
  return DateFormat('MMM d, yyyy h:mm a').format(dateTime);
}

Color _getPriorityColor(TaskPriority priority) {
  switch (priority) {
    case TaskPriority.high:
      return Colors.red.shade600;
    case TaskPriority.medium:
      return Colors.orange.shade600;
    case TaskPriority.low:
      return Colors.green.shade600;
  }
}
