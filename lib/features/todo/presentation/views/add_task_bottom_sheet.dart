import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/features/category/presentation/controllers/category_list_controller.dart';
import 'package:todo_app/features/todo/domain/entities/task.dart';
import 'package:todo_app/features/todo/presentation/controllers/todo_list_controller.dart';

class AddTaskBottomSheet extends ConsumerStatefulWidget {
  const AddTaskBottomSheet({super.key});

  @override
  ConsumerState<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends ConsumerState<AddTaskBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  String? _selectedCategoryId;
  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _selectedDueDate;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: _selectedDueDate != null
            ? TimeOfDay.fromDateTime(_selectedDueDate!)
            : TimeOfDay.now(),
      );

      if (time != null) {
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
        key: Key('priority_${priority.name}'),
        onTap: () {
          setState(() {
            _selectedPriority = priority;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? selectedBg.withAlpha(40)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? selectedBorder
                  : theme.colorScheme.outline.withAlpha(60),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: selectedBorder.withAlpha(30),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? selectedText
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  void _submitTask() async {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text.trim();
      final description = _descController.text.trim();

      await ref
          .read(todoListControllerProvider.notifier)
          .addTask(
            title: title,
            description: description.isEmpty ? null : description,
            categoryId: _selectedCategoryId,
            priority: _selectedPriority.name,
            dueDate: _selectedDueDate,
          );

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoryListControllerProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 8,
        left: 20,
        right: 20,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withAlpha(60),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Create New Task',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.onSurface.withAlpha(
                          15,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Title Input
                TextFormField(
                  key: const Key('taskTitleField'),
                  controller: _titleController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Task Title',
                    hintText: 'What needs to be done?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.edit_note),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Task title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description Input
                TextFormField(
                  key: const Key('taskDescriptionField'),
                  controller: _descController,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Add some details (optional)',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Icon(Icons.description_outlined),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Priority Selector Header
                Text(
                  'Priority',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),

                // Priority Row
                Row(
                  children: [
                    _buildPriorityButton(
                      TaskPriority.low,
                      'Low',
                      Colors.green.shade600,
                      Colors.green.shade700,
                      Colors.green,
                    ),
                    const SizedBox(width: 12),
                    _buildPriorityButton(
                      TaskPriority.medium,
                      'Medium',
                      Colors.orange.shade600,
                      Colors.orange.shade700,
                      Colors.orange,
                    ),
                    const SizedBox(width: 12),
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

                // Category and Due Date Row
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
                                key: const Key('categoryDropdown'),
                                initialValue: _selectedCategoryId,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
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
                                              overflow: TextOverflow.ellipsis,
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
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
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
                            key: const Key('dueDatePicker'),
                            onTap: _pickDueDateTime,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: theme.colorScheme.outline.withAlpha(
                                    120,
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    color: _selectedDueDate != null
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurfaceVariant,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _selectedDueDate == null
                                          ? 'Set Due Date'
                                          : _formatDateTime(_selectedDueDate!),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: _selectedDueDate != null
                                            ? theme.colorScheme.onSurface
                                            : theme.colorScheme.onSurfaceVariant
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
                const SizedBox(height: 28),

                // Submit Button
                ElevatedButton(
                  key: const Key('submitTaskButton'),
                  onPressed: _submitTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_task),
                      const SizedBox(width: 8),
                      Text(
                        'Create Task',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
