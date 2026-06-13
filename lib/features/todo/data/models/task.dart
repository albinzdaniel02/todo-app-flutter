import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'subtask.dart';
import '../../domain/entities/task.dart' as domain;

part 'task.g.dart';

@HiveType(typeId: 3)
enum TaskPriorityModel {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high;

  String get nameString => name;

  static TaskPriorityModel fromString(String? value) {
    if (value == null) return TaskPriorityModel.medium;
    return TaskPriorityModel.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => TaskPriorityModel.medium,
    );
  }

  domain.TaskPriority toDomain() {
    switch (this) {
      case TaskPriorityModel.low:
        return domain.TaskPriority.low;
      case TaskPriorityModel.medium:
        return domain.TaskPriority.medium;
      case TaskPriorityModel.high:
        return domain.TaskPriority.high;
    }
  }

  static TaskPriorityModel fromDomain(domain.TaskPriority priority) {
    switch (priority) {
      case domain.TaskPriority.low:
        return TaskPriorityModel.low;
      case domain.TaskPriority.medium:
        return TaskPriorityModel.medium;
      case domain.TaskPriority.high:
        return TaskPriorityModel.high;
    }
  }
}

@HiveType(typeId: 0)
class TaskModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2, defaultValue: '')
  final String description;

  @HiveField(3, defaultValue: false)
  final bool isCompleted;

  @HiveField(4, defaultValue: TaskPriorityModel.medium)
  final TaskPriorityModel priority;

  @HiveField(5)
  final DateTime? dueDate;

  @HiveField(6)
  final String? categoryId;

  @HiveField(7, defaultValue: [])
  final List<SubtaskModel> subtasks;

  @HiveField(8, defaultValue: false)
  final bool isArchived;

  @HiveField(9, defaultValue: false)
  final bool isDeleted;

  @HiveField(10)
  final DateTime createdAt;

  const TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.priority = TaskPriorityModel.medium,
    this.dueDate,
    this.categoryId,
    this.subtasks = const [],
    this.isArchived = false,
    this.isDeleted = false,
    required this.createdAt,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    TaskPriorityModel? priority,
    Object? dueDate = const Object(),
    Object? categoryId = const Object(),
    List<SubtaskModel>? subtasks,
    bool? isArchived,
    bool? isDeleted,
    DateTime? createdAt,
  }) {
    return TaskModel(
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

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      priority: TaskPriorityModel.fromString(json['priority'] as String?),
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'] as String)
          : null,
      categoryId: json['categoryId'] as String?,
      subtasks:
          (json['subtasks'] as List<dynamic>?)
              ?.map((e) => SubtaskModel.fromJson(e as Map<String, dynamic>))
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

  domain.Task toDomain() {
    return domain.Task(
      id: id,
      title: title,
      description: description,
      isCompleted: isCompleted,
      priority: priority.toDomain(),
      dueDate: dueDate,
      categoryId: categoryId,
      subtasks: subtasks.map((s) => s.toDomain()).toList(),
      isArchived: isArchived,
      isDeleted: isDeleted,
      createdAt: createdAt,
    );
  }

  factory TaskModel.fromDomain(domain.Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      isCompleted: task.isCompleted,
      priority: TaskPriorityModel.fromDomain(task.priority),
      dueDate: task.dueDate,
      categoryId: task.categoryId,
      subtasks: task.subtasks.map((s) => SubtaskModel.fromDomain(s)).toList(),
      isArchived: task.isArchived,
      isDeleted: task.isDeleted,
      createdAt: task.createdAt,
    );
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
