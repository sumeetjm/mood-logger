// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_memory_mapping.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskMemoryMappingAdapter extends TypeAdapter<TaskMemoryMapping> {
  @override
  final int typeId = 13;

  @override
  TaskMemoryMapping read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskMemoryMappingParse(
      id: fields[0] as String,
      isActive: fields[1] as bool,
      task: fields[3] as Task,
      memory: fields[4] as Memory,
      date: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TaskMemoryMapping obj) {
    writer
      ..writeByte(6)
      ..writeByte(3)
      ..write(obj.task)
      ..writeByte(4)
      ..write(obj.memory)
      ..writeByte(5)
      ..write(obj.date)
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
      other is TaskMemoryMappingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
