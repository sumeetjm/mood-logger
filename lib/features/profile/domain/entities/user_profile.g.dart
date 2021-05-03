// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 3;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfileParse(
      id: fields[0] as String,
      firstName: fields[3] as String,
      lastName: fields[4] as String,
      about: fields[5] as String,
      dateOfBirth: fields[6] as DateTime,
      profession: fields[7] as String,
      profilePicture: fields[8] as Media,
      profilePictureCollection: fields[9] as MediaCollection,
      gender: fields[10] as Gender,
      interestedIn: (fields[11] as List)?.cast<Gender>(),
      archiveMemoryCollection: fields[12] as MemoryCollection,
      isActive: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(13)
      ..writeByte(3)
      ..write(obj.firstName)
      ..writeByte(4)
      ..write(obj.lastName)
      ..writeByte(5)
      ..write(obj.about)
      ..writeByte(6)
      ..write(obj.dateOfBirth)
      ..writeByte(7)
      ..write(obj.profession)
      ..writeByte(8)
      ..write(obj.profilePicture)
      ..writeByte(9)
      ..write(obj.profilePictureCollection)
      ..writeByte(10)
      ..write(obj.gender)
      ..writeByte(11)
      ..write(obj.interestedIn)
      ..writeByte(12)
      ..write(obj.archiveMemoryCollection)
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
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
