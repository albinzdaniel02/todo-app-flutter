import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'subtask.dart';

part 'task.g.dart';

@HiveType(typeId: 3)
enum TaskPriority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
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

@HiveType(typeId: 0)
class Task extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2, defaultValue: '')
  final String description;

  @HiveField(3, defaultValue: false)
  final bool isCompleted;

  @HiveField(4, defaultValue: TaskPriority.medium)
  final TaskPriority priority;

  @HiveField(5)
  final DateTime? dueDate;

  @HiveField(6)
  final String? categoryId;

  @HiveField(7, defaultValue: [])
  final List<Subtask> subtasks;

  @HiveField(8, defaultValue: false)
  final bool isArchived;

  @HiveField(9, defaultValue: false)
  final bool isDeleted;

  @HiveField(10)
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
      subtasks:
          (json['subtasks'] as List<dynamic>?)
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
