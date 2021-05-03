// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_repeat.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskRepeatAdapter extends TypeAdapter<TaskRepeat> {
  @override
  final int typeId = 12;

  @override
  TaskRepeat read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskRepeatParse(
      id: fields[0] as String,
      repeatType: fields[3] as String,
      selectedDateList: (fields[4] as List)?.cast<DateTime>(),
      isActive: fields[1] as bool,
      validUpto: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TaskRepeat obj) {
    writer
      ..writeByte(6)
      ..writeByte(3)
      ..write(obj.repeatType)
      ..writeByte(4)
      ..write(obj.selectedDateList)
      ..writeByte(5)
      ..write(obj.validUpto)
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
      other is TaskRepeatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
