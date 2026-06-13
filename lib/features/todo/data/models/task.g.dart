// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskModelAdapter extends TypeAdapter<TaskModel> {
  @override
  final int typeId = 0;

  @override
  TaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] == null ? '' : fields[2] as String,
      isCompleted: fields[3] == null ? false : fields[3] as bool,
      priority: fields[4] == null
          ? TaskPriorityModel.medium
          : fields[4] as TaskPriorityModel,
      dueDate: fields[5] as DateTime?,
      categoryId: fields[6] as String?,
      subtasks: fields[7] == null
          ? []
          : (fields[7] as List).cast<SubtaskModel>(),
      isArchived: fields[8] == null ? false : fields[8] as bool,
      isDeleted: fields[9] == null ? false : fields[9] as bool,
      createdAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.dueDate)
      ..writeByte(6)
      ..write(obj.categoryId)
      ..writeByte(7)
      ..write(obj.subtasks)
      ..writeByte(8)
      ..write(obj.isArchived)
      ..writeByte(9)
      ..write(obj.isDeleted)
      ..writeByte(10)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskPriorityModelAdapter extends TypeAdapter<TaskPriorityModel> {
  @override
  final int typeId = 3;

  @override
  TaskPriorityModel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskPriorityModel.low;
      case 1:
        return TaskPriorityModel.medium;
      case 2:
        return TaskPriorityModel.high;
      default:
        return TaskPriorityModel.low;
    }
  }

  @override
  void write(BinaryWriter writer, TaskPriorityModel obj) {
    switch (obj) {
      case TaskPriorityModel.low:
        writer.writeByte(0);
        break;
      case TaskPriorityModel.medium:
        writer.writeByte(1);
        break;
      case TaskPriorityModel.high:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskPriorityModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
