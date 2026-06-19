import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:todo_app/features/category/presentation/controllers/category_list_controller.dart';
import 'package:todo_app/features/todo/domain/entities/task.dart';
import 'package:todo_app/features/todo/domain/entities/subtask.dart';
import 'package:todo_app/features/todo/presentation/controllers/todo_list_controller.dart';

class TaskDetailPane extends ConsumerWidget {
  const TaskDetailPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTaskId = ref.watch(selectedTaskIdProvider);
    final tasksAsync = ref.watch(todoListControllerProvider);

    if (selectedTaskId == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Colors.grey,
              key: Key('placeholderIcon'),
            ),
            SizedBox(height: 16),
            Text(
              'Select a task to view details',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              key: Key('placeholderText'),
            ),
          ],
        ),
      );
    }

    return tasksAsync.when(
      data: (tasks) {
        Task? task;
        for (final t in tasks) {
          if (t.id == selectedTaskId) {
            task = t;
            break;
          }
        }

        if (task == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Select a task to view details',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return TaskDetailEditor(key: ValueKey(task.id), task: task);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
      ),
    );
  }
}

class TaskDetailEditor extends ConsumerStatefulWidget {
  final Task task;

  const TaskDetailEditor({required this.task, super.key});

  @override
  ConsumerState<TaskDetailEditor> createState() => _TaskDetailEditorState();
}

class _TaskDetailEditorState extends ConsumerState<TaskDetailEditor> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  final TextEditingController _newSubtaskController = TextEditingController();

  String? _selectedCategoryId;
  late TaskPriority _selectedPriority;
  DateTime? _selectedDueDate;
  late List<Subtask> _subtasks;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description);
    _selectedCategoryId = widget.task.categoryId;
    _selectedPriority = widget.task.priority;
    _selectedDueDate = widget.task.dueDate;
    _subtasks = List.from(widget.task.subtasks);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _newSubtaskController.dispose();
    super.dispose();
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

  Future<void> _pickDueDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: _selectedDueDate != null
            ? TimeOfDay.fromDateTime(_selectedDueDate!)
            : TimeOfDay.now(),
      );

      if (time != null && mounted) {
        setState(() {
          _selectedDueDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _addSubtask() {
    final text = _newSubtaskController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _subtasks.add(
          Subtask(id: const Uuid().v4(), title: text, isCompleted: false),
        );
      });
      _newSubtaskController.clear();
    }
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final updatedTask = widget.task.copyWith(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        categoryId: _selectedCategoryId,
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
        subtasks: _subtasks,
      );

      await ref
          .read(todoListControllerProvider.notifier)
          .updateTask(updatedTask);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task updated successfully!'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _deleteTask() async {
    final title = widget.task.title;
    final taskId = widget.task.id;
    final todoListController = ref.read(todoListControllerProvider.notifier);

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text('"$title" moved to trash'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            todoListController.restoreTask(taskId);
          },
        ),
      ),
    );

    ref.read(selectedTaskIdProvider.notifier).select(null);
    await todoListController.softDeleteTask(taskId);
  }


  Widget _buildPriorityButton(
    TaskPriority priority,
    String label,
    Color selectedBg,
    Color selectedText,
    Color selectedBorder,
  ) {
    final isSelected = _selectedPriority == priority;
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        key: Key('detailPriority_${priority.name}'),
        onTap: () {
          setState(() {
            _selectedPriority = priority;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? selectedBg.withAlpha(40)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? selectedBorder
                  : theme.colorScheme.outline.withAlpha(60),
              width: isSelected ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? selectedText
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoryListControllerProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pane Header / Title block
            Text(
              'Task Details',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const Divider(height: 32),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    TextFormField(
                      key: const Key('detailTitleField'),
                      controller: _titleController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: 'Task Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Task title is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      key: const Key('detailDescriptionField'),
                      controller: _descController,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 50),
                          child: Icon(Icons.description_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Priority
                    Text(
                      'Priority',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildPriorityButton(
                          TaskPriority.low,
                          'Low',
                          Colors.green.shade600,
                          Colors.green.shade700,
                          Colors.green,
                        ),
                        const SizedBox(width: 8),
                        _buildPriorityButton(
                          TaskPriority.medium,
                          'Medium',
                          Colors.orange.shade600,
                          Colors.orange.shade700,
                          Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        _buildPriorityButton(
                          TaskPriority.high,
                          'High',
                          Colors.red.shade600,
                          Colors.red.shade700,
                          Colors.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Category & Due Date Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Selection
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Category',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              categoriesAsync.when(
                                data: (categories) {
                                  return DropdownButtonFormField<String>(
                                    key: const Key('detailCategoryDropdown'),
                                    initialValue: _selectedCategoryId,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    hint: const Text('No Tag'),
                                    icon: const Icon(Icons.arrow_drop_down),
                                    items: [
                                      const DropdownMenuItem<String>(
                                        value: null,
                                        child: Text('No Tag'),
                                      ),
                                      ...categories.map((category) {
                                        final color = _parseHexColor(
                                          category.colorHex,
                                        );
                                        return DropdownMenuItem<String>(
                                          value: category.id,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 12,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  color: color,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Flexible(
                                                child: Text(
                                                  category.name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ],
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedCategoryId = val;
                                      });
                                    },
                                  );
                                },
                                loading: () => const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                error: (err, stack) => const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Due Date Selection
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Due Date',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                key: const Key('detailDueDatePicker'),
                                onTap: _pickDueDateTime,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: theme.colorScheme.outline
                                          .withAlpha(120),
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month,
                                        color: _selectedDueDate != null
                                            ? theme.colorScheme.primary
                                            : theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _selectedDueDate == null
                                              ? 'Set Due Date'
                                              : _formatDateTime(
                                                  _selectedDueDate!,
                                                ),
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: _selectedDueDate != null
                                                ? theme.colorScheme.onSurface
                                                : theme
                                                      .colorScheme
                                                      .onSurfaceVariant
                                                      .withAlpha(150),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (_selectedDueDate != null)
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedDueDate = null;
                                            });
                                          },
                                          child: Icon(
                                            Icons.clear,
                                            size: 16,
                                            color: theme.colorScheme.error,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Subtasks Checklist
                    Text(
                      'Subtasks',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtask items list
                    if (_subtasks.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _subtasks.length,
                        itemBuilder: (context, index) {
                          final subtask = _subtasks[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              children: [
                                Checkbox(
                                  key: Key(
                                    'detailSubtaskCheckbox_${subtask.id}',
                                  ),
                                  value: subtask.isCompleted,
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _subtasks[index] = subtask.copyWith(
                                          isCompleted: val,
                                        );
                                      });
                                    }
                                  },
                                ),
                                Expanded(
                                  child: Text(
                                    subtask.title,
                                    style: TextStyle(
                                      decoration: subtask.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: subtask.isCompleted
                                          ? theme.colorScheme.onSurface
                                                .withAlpha(120)
                                          : null,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  key: Key('detailSubtaskDelete_${subtask.id}'),
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: theme.colorScheme.error,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _subtasks.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 8),
                    // Add Subtask input field
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            key: const Key('detailAddSubtaskField'),
                            controller: _newSubtaskController,
                            decoration: InputDecoration(
                              hintText: 'Add a subtask...',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onSubmitted: (_) => _addSubtask(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          key: const Key('detailAddSubtaskButton'),
                          icon: const Icon(Icons.add),
                          onPressed: _addSubtask,
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            foregroundColor:
                                theme.colorScheme.onPrimaryContainer,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Actions buttons row at the very bottom
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    key: const Key('detailDeleteButton'),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _deleteTask,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    key: const Key('detailSaveButton'),
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _saveTask,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
