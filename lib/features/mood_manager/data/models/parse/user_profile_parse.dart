import 'package:dartz/dartz.dart';
import 'package:mood_manager/features/mood_manager/data/models/parse/collection_parse.dart';
import 'package:mood_manager/features/mood_manager/data/models/parse/gender_parse.dart';
import 'package:mood_manager/features/mood_manager/data/models/parse/media_collection_parse.dart';
import 'package:mood_manager/features/mood_manager/data/models/parse/photo_parse.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/base.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/collection.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/gender.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/media.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/user_profile.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

import 'base_parse_mixin.dart';

class UserProfileParse extends UserProfile with ParseMixin {
  UserProfileParse({
    String id,
    String firstName,
    String lastName,
    String about,
    DateTime dateOfBirth,
    String profession,
    ParseUser user,
    Media profilePicture,
    bool isActive,
    Gender gender,
    List<Gender> interestedIn,
    Collection profilePictureCollection,
  }) : super(
          id: id,
          firstName: firstName,
          lastName: lastName,
          about: about,
          dateOfBirth: dateOfBirth,
          profession: profession,
          user: user,
          profilePicture: profilePicture,
          isActive: isActive,
          gender: gender,
          interestedIn: interestedIn,
          profilePictureCollection: profilePictureCollection,
        );

  static UserProfileParse from(ParseObject parseObject,
      {UserProfileParse cacheData, List<String> cacheKeys = const []}) {
    if (parseObject == null) {
      return null;
    }
    final parseOptions = {
      'cacheData': cacheData,
      'cacheKeys': cacheKeys ?? [],
      'data': parseObject,
    };
    return UserProfileParse(
      id: ParseMixin.value('objectId', parseOptions),
      firstName: ParseMixin.value('firstName', parseOptions),
      lastName: ParseMixin.value('lastName', parseOptions),
      about: ParseMixin.value('about', parseOptions),
      dateOfBirth: ParseMixin.value('dateOfBirth', parseOptions)?.toLocal(),
      profession: ParseMixin.value('profession', parseOptions),
      user: ParseMixin.value('user', parseOptions),
      profilePicture: ParseMixin.value('profilePicture', parseOptions,
          transform: MediaParse.from),
      profilePictureCollection: ParseMixin.value(
          'profilePictureCollection', parseOptions,
          transform: CollectionParse.from),
      gender:
          ParseMixin.value('gender', parseOptions, transform: GenderParse.from),
      interestedIn: List<Gender>.from(ParseMixin.value(
          'interestedIn', parseOptions,
          transform: GenderParse.from)),
      isActive: ParseMixin.value(
        'isActive',
        parseOptions,
      ),
    );
  }

  Map<String, dynamic> get map {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'about': about,
      'dateOfBirth': dateOfBirth?.toUtc(),
      'profession': profession,
      'user': user,
      'isActive': isActive,
      'profilePicture': profilePicture,
      'profilePictureCollection': profilePictureCollection,
      'gender': gender,
      'interestedIn': interestedIn
    };
  }

  @override
  Base get get => this;
}
