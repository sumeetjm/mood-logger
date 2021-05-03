// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MediaAdapter extends TypeAdapter<Media> {
  @override
  final int typeId = 4;

  @override
  Media read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MediaParse(
      id: fields[0] as String,
      file: fields[3] == null
          ? null
          : ((fields[3] as String).startsWith('http')
              ? ParseFile(null,
                  url: (fields[3] as String),
                  name: (fields[4] as String)
                      .substring((fields[4] as String).lastIndexOf('/')))
              : ParseFile(File((fields[3] as String)))),
      thumbnail: fields[4] == null
          ? null
          : ((fields[4] as String).startsWith('http')
              ? ParseFile(null,
                  url: (fields[4] as String),
                  name: (fields[4] as String)
                      .substring((fields[4] as String).lastIndexOf('/')))
              : ParseFile(File((fields[4] as String)))),
      mediaType: fields[5] as String,
      isActive: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Media obj) {
    writer
      ..writeByte(6)
      ..writeByte(3)
      ..write(obj.file?.url ?? obj.file?.file?.path)
      ..writeByte(4)
      ..write(obj.thumbnail?.url ?? obj.thumbnail?.file?.path)
      ..writeByte(5)
      ..write(obj.mediaType)
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
      other is MediaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
