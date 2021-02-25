import 'package:flutter/material.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/memory/domain/entities/memory_collection.dart';
import 'package:mood_manager/features/metadata/domain/entities/gender.dart';
import 'package:mood_manager/features/common/domain/entities/media.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

import '../../../common/domain/entities/base.dart';

class UserProfile extends Base {
  final String firstName;
  final String lastName;
  final String about;
  final DateTime dateOfBirth;
  final String profession;
  final ParseUser user;
  final Media profilePicture;
  final MediaCollection profilePictureCollection;
  final Gender gender;
  final List<Gender> interestedIn;
  MemoryCollection archiveMemoryCollection;
  UserProfile({
    String id,
    @required this.firstName,
    @required this.lastName,
    @required this.about,
    @required this.dateOfBirth,
    @required this.profession,
    @required this.user,
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
}
