// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_collection.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MemoryCollectionAdapter extends TypeAdapter<MemoryCollection> {
  @override
  final int typeId = 7;

  @override
  MemoryCollection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MemoryCollectionParse(
      id: fields[0] as String,
      name: fields[3] as String,
      code: fields[4] as String,
      isActive: fields[1] as bool,
      averageMemoryMoodColor: HexColor.fromHex(fields[5]),
      memoryCount: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, MemoryCollection obj) {
    writer
      ..writeByte(7)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.code)
      ..writeByte(5)
      ..write(obj.averageMemoryMoodColor?.toHex())
      ..writeByte(6)
      ..write(obj.memoryCount)
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
      other is MemoryCollectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
