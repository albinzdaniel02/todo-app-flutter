import 'package:equatable/equatable.dart';
import 'subtask.dart';

enum TaskPriority {
  low,
  medium,
  high;

  String get nameString => name;

  static TaskPriority fromString(String? value) {
    if (value == null) return TaskPriority.medium;
    return TaskPriority.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => TaskPriority.medium,
    );
  }
}

class Task extends Equatable {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final TaskPriority priority;
  final DateTime? dueDate;
  final String? categoryId;
  final List<Subtask> subtasks;
  final bool isArchived;
  final bool isDeleted;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.categoryId,
    this.subtasks = const [],
    this.isArchived = false,
    this.isDeleted = false,
    required this.createdAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    TaskPriority? priority,
    Object? dueDate = const Object(),
    Object? categoryId = const Object(),
    List<Subtask>? subtasks,
    bool? isArchived,
    bool? isDeleted,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      dueDate: dueDate == const Object() ? this.dueDate : dueDate as DateTime?,
      categoryId: categoryId == const Object()
          ? this.categoryId
          : categoryId as String?,
      subtasks: subtasks ?? this.subtasks,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      priority: TaskPriority.fromString(json['priority'] as String?),
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'] as String)
          : null,
      categoryId: json['categoryId'] as String?,
      subtasks: (json['subtasks'] as List<dynamic>?)
              ?.map((e) => Subtask.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isArchived: json['isArchived'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'priority': priority.name,
      'dueDate': dueDate?.toIso8601String(),
      'categoryId': categoryId,
      'subtasks': subtasks.map((e) => e.toJson()).toList(),
      'isArchived': isArchived,
      'isDeleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        isCompleted,
        priority,
        dueDate,
        categoryId,
        subtasks,
        isArchived,
        isDeleted,
        createdAt,
      ];
}
