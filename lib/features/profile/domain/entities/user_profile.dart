import 'package:flutter/material.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/memory/domain/entities/memory_collection.dart';
import 'package:mood_manager/features/metadata/domain/entities/gender.dart';
import 'package:mood_manager/features/common/domain/entities/media.dart';
import 'package:mood_manager/features/profile/data/models/user_profile_parse.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:hive/hive.dart';
import '../../../common/domain/entities/base.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 3)
class UserProfile extends Base {
  @HiveField(3)
  final String firstName;
  @HiveField(4)
  final String lastName;
  @HiveField(5)
  String about;
  @HiveField(6)
  DateTime dateOfBirth;
  @HiveField(7)
  String profession;
  ParseUser user;
  @HiveField(8)
  Media profilePicture;
  @HiveField(9)
  final MediaCollection profilePictureCollection;
  @HiveField(10)
  Gender gender;
  @HiveField(11)
  List<Gender> interestedIn;
  @HiveField(12)
  MemoryCollection archiveMemoryCollection;
  UserProfile({
    String id,
    @required this.firstName,
    @required this.lastName,
    @required this.about,
    @required this.dateOfBirth,
    @required this.profession,
    this.user,
    @required this.profilePicture,
    @required this.profilePictureCollection,
    @required this.gender,
    @required this.interestedIn,
    this.archiveMemoryCollection,
    bool isActive = true,
  }) : super(
          id: id,
          isActive: isActive,
          className: 'userDtl',
        );

  String get name => ((firstName ?? '') + ' ' + (lastName ?? '')).trim();

  void set name(value) => value;
}
