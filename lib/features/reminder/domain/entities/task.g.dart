// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 11;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskParse(
      id: fields[0] as String,
      title: fields[3] as String,
      note: fields[4] as String,
      mActivityList: (fields[5] as List)?.cast<MActivity>(),
      isActive: fields[1] as bool,
      taskDateTime: fields[6] as DateTime,
      notificationDateTime: fields[7] as DateTime,
      color: HexColor.fromHex(fields[8]),
      taskRepeat: fields[9] as TaskRepeat,
      memoryMapByDate: (fields[10] as Map)?.cast<DateTime, Memory>(),
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) async {
    writer
      ..writeByte(11)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.note)
      ..writeByte(5)
      ..write(obj.mActivityList)
      ..writeByte(6)
      ..write(obj.taskDateTime)
      ..writeByte(7)
      ..write(obj.notificationDateTime)
      ..writeByte(8)
      ..write(obj.color?.toHex())
      ..writeByte(9)
      ..write(obj.taskRepeat)
      ..writeByte(10)
      ..write(obj.memoryMapByDate)
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
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
