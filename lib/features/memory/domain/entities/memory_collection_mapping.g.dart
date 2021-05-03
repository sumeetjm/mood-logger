// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_collection_mapping.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MemoryCollectionMappingAdapter
    extends TypeAdapter<MemoryCollectionMapping> {
  @override
  final int typeId = 10;

  @override
  MemoryCollectionMapping read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MemoryCollectionMappingParse(
      id: fields[0] as String,
      memoryCollection: fields[3] as MemoryCollection,
      memory: fields[4] as Memory,
      isActive: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MemoryCollectionMapping obj) {
    writer
      ..writeByte(5)
      ..writeByte(3)
      ..write(obj.memoryCollection)
      ..writeByte(4)
      ..write(obj.memory)
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
      other is MemoryCollectionMappingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
