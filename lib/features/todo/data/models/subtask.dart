import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/subtask.dart';

part 'subtask.g.dart';

@HiveType(typeId: 1)
class SubtaskModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2, defaultValue: false)
  final bool isCompleted;

  const SubtaskModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  SubtaskModel copyWith({String? id, String? title, bool? isCompleted}) {
    return SubtaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory SubtaskModel.fromJson(Map<String, dynamic> json) {
    return SubtaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'isCompleted': isCompleted};
  }

  Subtask toDomain() {
    return Subtask(
      id: id,
      title: title,
      isCompleted: isCompleted,
    );
  }

  factory SubtaskModel.fromDomain(Subtask domain) {
    return SubtaskModel(
      id: domain.id,
      title: domain.title,
      isCompleted: domain.isCompleted,
    );
  }

  @override
  List<Object?> get props => [id, title, isCompleted];
}
