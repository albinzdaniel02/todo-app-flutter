import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/features/category/domain/entities/category.dart';
import 'package:todo_app/features/category/presentation/controllers/category_list_controller.dart';
import 'package:todo_app/features/todo/domain/entities/task.dart';
import 'package:todo_app/features/todo/presentation/controllers/todo_list_controller.dart';

class TrashView extends ConsumerWidget {
  const TrashView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trashedTasksAsync = ref.watch(trashedTasksListProvider);
    final categoriesAsync = ref.watch(categoryListControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash'),
        elevation: 0,
        actions: [
          trashedTasksAsync.when(
            data: (tasks) {
              if (tasks.isEmpty) return const SizedBox.shrink();
              return TextButton.icon(
                key: const Key('emptyTrashButton'),
                icon: Icon(Icons.delete_sweep, color: theme.colorScheme.error),
                label: Text(
                  'Empty Trash',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                onPressed: () => _showEmptyTrashConfirmation(context, ref),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: trashedTasksAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 64,
                    color: theme.colorScheme.onSurface.withAlpha(80),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Trash is empty',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(150),
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

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: theme.colorScheme.outline.withAlpha(40),
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    decoration: task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                if (task.description.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    task.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // Actions
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                key: Key('restore_${task.id}'),
                                icon: const Icon(Icons.restore),
                                tooltip: 'Restore task',
                                onPressed: () async {
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );
                                  await ref
                                      .read(todoListControllerProvider.notifier)
                                      .restoreTask(task.id);
                                  messenger.hideCurrentSnackBar();
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text('"${task.title}" restored'),
                                      duration: const Duration(seconds: 4),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                key: Key('delete_perm_${task.id}'),
                                icon: Icon(
                                  Icons.delete_forever,
                                  color: theme.colorScheme.error,
                                ),
                                tooltip: 'Delete permanently',
                                onPressed: () =>
                                    _showDeletePermanentlyConfirmation(
                                      context,
                                      ref,
                                      task,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Badges Row
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _Badge(
                            label: task.priority.name.toUpperCase(),
                            color: _getPriorityColor(task.priority),
                          ),
                          if (taskCategory != null)
                            _Badge(
                              label: taskCategory!.name,
                              color: _parseHexColor(taskCategory!.colorHex),
                            ),
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
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text('Error loading trashed tasks: $err')),
      ),
    );
  }

  void _showEmptyTrashConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Empty Trash?'),
        content: const Text(
          'This action will permanently delete all tasks in the trash and cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            key: const Key('confirmEmptyTrashButton'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await ref.read(todoListControllerProvider.notifier).emptyTrash();
              if (context.mounted) {
                Navigator.pop(context);
              }
              messenger.hideCurrentSnackBar();
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Trash emptied'),
                  duration: Duration(seconds: 4),
                ),
              );
            },
            child: const Text('Empty Trash'),
          ),
        ],
      ),
    );
  }

  void _showDeletePermanentlyConfirmation(
    BuildContext context,
    WidgetRef ref,
    Task task,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Permanently?'),
        content: Text(
          'Are you sure you want to permanently delete "${task.title}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            key: Key('confirmDeletePerm_${task.id}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await ref
                  .read(todoListControllerProvider.notifier)
                  .deletePermanently(task.id);
              if (context.mounted) {
                Navigator.pop(context);
              }
              messenger.hideCurrentSnackBar();
              messenger.showSnackBar(
                SnackBar(
                  content: Text('"${task.title}" permanently deleted'),
                  duration: const Duration(seconds: 4),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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
