// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_collection_mapping.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MediaCollectionMappingAdapter
    extends TypeAdapter<MediaCollectionMapping> {
  @override
  final int typeId = 8;

  @override
  MediaCollectionMapping read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MediaCollectionMappingParse(
      id: fields[0] as String,
      media: fields[3] as Media,
      collection: fields[4] as MediaCollection,
      isActive: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MediaCollectionMapping obj) {
    writer
      ..writeByte(5)
      ..writeByte(3)
      ..write(obj.media)
      ..writeByte(4)
      ..write(obj.collection)
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
      other is MediaCollectionMappingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
