// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MemoryAdapter extends TypeAdapter<Memory> {
  @override
  final int typeId = 9;

  @override
  Memory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MemoryParse(
      id: fields[0] as String,
      title: fields[3] as String,
      note: fields[4] as String,
      mMood: fields[5] as MMood,
      mActivityList: (fields[7] as List)?.cast<MActivity>(),
      collectionList: (fields[6] as List)?.cast<MediaCollection>(),
      isActive: fields[1] as bool,
      logDateTime: fields[8] as DateTime,
      isArchived: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Memory obj) {
    writer
      ..writeByte(10)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.note)
      ..writeByte(5)
      ..write(obj.mMood)
      ..writeByte(6)
      ..write(obj.mediaCollectionList)
      ..writeByte(7)
      ..write(obj.mActivityList)
      ..writeByte(8)
      ..write(obj.logDateTime)
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
      other is MemoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
