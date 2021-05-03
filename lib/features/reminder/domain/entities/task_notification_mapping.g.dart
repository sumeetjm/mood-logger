// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_notification_mapping.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskNotificationMappingAdapter
    extends TypeAdapter<TaskNotificationMapping> {
  @override
  final int typeId = 14;

  @override
  TaskNotificationMapping read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskNotificationMappingParse(
      id: fields[0] as String,
      task: fields[3] as Task,
      notifyDateTime: fields[4] as DateTime,
      localNotificationId: fields[5] as int,
      isActive: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TaskNotificationMapping obj) {
    writer
      ..writeByte(6)
      ..writeByte(3)
      ..write(obj.task)
      ..writeByte(4)
      ..write(obj.notifyDateTime)
      ..writeByte(5)
      ..write(obj.localNotificationId)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.isActive)
      ..writeByte(2)
      ..write(obj.className);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskNotificationMappingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
