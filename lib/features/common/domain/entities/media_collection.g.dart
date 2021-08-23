// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_collection.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MediaCollectionAdapter extends TypeAdapter<MediaCollection> {
  @override
  final int typeId = 5;

  @override
  MediaCollection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MediaCollectionParse(
      id: fields[0] as String,
      name: fields[4] as String,
      code: fields[5] as String,
      module: fields[6] as String,
      mediaType: fields[3] as String,
      imageCount: fields[7] as int,
      videoCount: fields[8] as int,
      mediaCount: fields[9] as int,
      isActive: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MediaCollection obj) {
    writer
      ..writeByte(8)
      ..writeByte(3)
      ..write(obj.mediaType)
      ..writeByte(4)
      ..write(obj.name)
      ..writeByte(5)
      ..write(obj.code)
      ..writeByte(6)
      ..write(obj.module)
      ..writeByte(7)
      ..write(obj.imageCount)
      ..writeByte(8)
      ..write(obj.videoCount)
      ..writeByte(9)
      ..write(obj.mediaCount)
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
      other is MediaCollectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
