// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'm_activity_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MActivityTypeAdapter extends TypeAdapter<MActivityType> {
  @override
  final int typeId = 2;

  @override
  MActivityType read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MActivityTypeParse(
      activityTypeName: fields[3] as String,
      activityTypeCode: fields[4] as String,
      isActive: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MActivityType obj) {
    writer
      ..writeByte(5)
      ..writeByte(3)
      ..write(obj.activityTypeName)
      ..writeByte(4)
      ..write(obj.activityTypeCode)
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
      other is MActivityTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
