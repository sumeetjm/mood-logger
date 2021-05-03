// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'm_mood.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MMoodAdapter extends TypeAdapter<MMood> {
  @override
  final int typeId = 0;

  @override
  MMood read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MMoodParse(
      moodName: fields[3] as String,
      moodCode: fields[4] as String,
      isActive: fields[1] as bool,
      color: HexColor.fromHex(fields[5]),
      mMoodList: (fields[6] as List)?.cast<MMood>(),
    );
  }

  @override
  void write(BinaryWriter writer, MMood obj) {
    writer
      ..writeByte(7)
      ..writeByte(3)
      ..write(obj.moodName)
      ..writeByte(4)
      ..write(obj.moodCode)
      ..writeByte(5)
      ..write(obj.color?.toHex())
      ..writeByte(6)
      ..write(obj.mMoodList)
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
      other is MMoodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
