import 'package:flutter/material.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/collection.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/gender.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/media.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

import 'base.dart';

class UserProfile extends Base {
  final String firstName;
  final String lastName;
  final String about;
  final DateTime dateOfBirth;
  final String profession;
  final ParseUser user;
  final Media profilePicture;
  final Collection profilePictureCollection;
  final Gender gender;
  final List<Gender> interestedIn;
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
    bool isActive = true,
  }) : super(
          id: id,
          isActive: isActive,
          className: 'userDtl',
        );
}
