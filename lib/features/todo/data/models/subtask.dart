import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'subtask.g.dart';

@HiveType(typeId: 1)
class Subtask extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2, defaultValue: false)
  final bool isCompleted;

  const Subtask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  Subtask copyWith({String? id, String? title, bool? isCompleted}) {
    return Subtask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory Subtask.fromJson(Map<String, dynamic> json) {
    return Subtask(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'isCompleted': isCompleted};
  }

  @override
  List<Object?> get props => [id, title, isCompleted];
}
