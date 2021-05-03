// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'm_activity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MActivityAdapter extends TypeAdapter<MActivity> {
  @override
  final int typeId = 1;

  @override
  MActivity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MActivityParse(
      activityName: fields[3] as String,
      activityCode: fields[4] as String,
      isActive: fields[1] as bool,
      mActivityType: fields[5] as MActivityType,
    );
  }

  @override
  void write(BinaryWriter writer, MActivity obj) {
    writer
      ..writeByte(6)
      ..writeByte(3)
      ..write(obj.activityName)
      ..writeByte(4)
      ..write(obj.activityCode)
      ..writeByte(5)
      ..write(obj.mActivityType)
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
      other is MActivityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
