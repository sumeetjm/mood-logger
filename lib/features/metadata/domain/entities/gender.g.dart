// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gender.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GenderAdapter extends TypeAdapter<Gender> {
  @override
  final int typeId = 6;

  @override
  Gender read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GenderParse(
      id: fields[0] as String,
      name: fields[4] as String,
      code: fields[5] as String,
      altName: fields[3] as String,
      iconKey: fields[6],
      isActive: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Gender obj) {
    writer
      ..writeByte(7)
      ..writeByte(3)
      ..write(obj.altName)
      ..writeByte(4)
      ..write(obj.name)
      ..writeByte(5)
      ..write(obj.code)
      ..writeByte(6)
      ..write(obj.iconKey)
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
      other is GenderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
