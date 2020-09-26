import 'package:flutter/material.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/city.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/country.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/gender.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/photo.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/region.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

import 'base_m.dart';

class UserProfile extends BaseM {
  final String firstName;
  final String lastName;
  final String about;
  final DateTime dateOfBirth;
  final String profession;
  final City city;
  final ParseUser user;
  final Country country;
  final Region region;
  final Photo profilePicture;
  final Gender gender;

  UserProfile({
    String id,
    @required this.firstName,
    @required this.lastName,
    @required this.about,
    @required this.dateOfBirth,
    @required this.profession,
    @required this.city,
    @required this.country,
    @required this.user,
    @required this.region,
    @required this.profilePicture,
    @required this.gender,
    bool isActive = true,
  }) : super(
          id: id,
          name: firstName + ' ' + lastName,
          code: firstName + ' ' + lastName,
          isActive: isActive,
          className: 'userDtl',
        );
}
