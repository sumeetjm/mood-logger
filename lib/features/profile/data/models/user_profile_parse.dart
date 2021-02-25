import 'package:dartz/dartz.dart';
import 'package:mood_manager/features/common/data/models/media_collection_parse.dart';
import 'package:mood_manager/features/memory/data/models/memory_collection_parse.dart';
import 'package:mood_manager/features/memory/domain/entities/memory_collection.dart';
import 'package:mood_manager/features/metadata/data/models/gender_parse.dart';
import 'package:mood_manager/features/common/data/models/media_collection_mapping_parse.dart';
import 'package:mood_manager/features/common/data/models/media_parse.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/metadata/domain/entities/gender.dart';
import 'package:mood_manager/features/common/domain/entities/media.dart';
import 'package:mood_manager/features/profile/domain/entities/user_profile.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

import '../../../common/data/models/parse_mixin.dart';

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
    bool isActive = true,
    Gender gender,
    List<Gender> interestedIn,
    MediaCollection profilePictureCollection,
    MemoryCollection archiveMemoryCollection,
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
          archiveMemoryCollection: archiveMemoryCollection,
        );

  static UserProfileParse from(ParseObject parseObject,
      {UserProfileParse cacheData,
      List<String> cacheKeys = const [],
      List<String> notCacheKeys = const []}) {
    if (parseObject == null) {
      return null;
    }
    final parseOptions = {
      'cacheData': cacheData,
      'cacheKeys': notCacheKeys.isEmpty
          ? cacheKeys ?? []
          : cacheData.map.keys
              .where((element) => !notCacheKeys.contains(element))
              .toList(),
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
          transform: MediaCollectionParse.from),
      gender:
          ParseMixin.value('gender', parseOptions, transform: GenderParse.from),
      interestedIn: List<Gender>.from(ParseMixin.value(
          'interestedIn', parseOptions,
          transform: GenderParse.from)),
      isActive: ParseMixin.value(
        'isActive',
        parseOptions,
      ),
      archiveMemoryCollection: ParseMixin.value(
          'archiveMemoryCollection', parseOptions,
          transform: MemoryCollectionParse.from),
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
      'interestedIn': interestedIn,
      'archiveMemoryCollection': archiveMemoryCollection,
    };
  }

  @override
  Base get get => this;
}
