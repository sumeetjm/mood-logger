import 'package:dartz/dartz.dart' show cast;
import 'package:mood_manager/features/common/data/datasources/common_remote_data_source.dart';
import 'package:mood_manager/features/common/data/models/parse_mixin.dart';
import 'package:mood_manager/features/common/data/models/media_collection_parse.dart';
import 'package:mood_manager/features/common/data/models/media_collection_mapping_parse.dart';
import 'package:mood_manager/features/common/data/models/media_parse.dart';
import 'package:mood_manager/features/profile/data/models/user_profile_parse.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/common/domain/entities/media.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection_mapping.dart';
import 'package:mood_manager/features/profile/domain/entities/user_profile.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

import '../../../../core/error/exceptions.dart';

abstract class UserProfileRemoteDataSource {
  Future<UserProfile> getUserProfile(ParseUser user);
  Future<UserProfile> getCurrentUserProfile();
  Future<UserProfile> saveUserProfile(UserProfile userProfile);
  Future<MediaCollectionMapping> saveProfilePicture(
      final MediaCollectionMapping mediaCollectionMapping,
      final UserProfile userProfile);
}

class UserProfileParseDataSource implements UserProfileRemoteDataSource {
  final CommonRemoteDataSource commonRemoteDataSource;

  UserProfileParseDataSource({this.commonRemoteDataSource});
  @override
  Future<UserProfile> getUserProfile(ParseUser user) async {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('userDtl'))
          ..whereEqualTo('user', user.toPointer())
          ..whereEqualTo('isActive', true);

    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      UserProfile userProfileParse =
          UserProfileParse.from(response.results.first);
      return userProfileParse;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<UserProfile> getCurrentUserProfile() async {
    ParseUser currentUser = await ParseUser.currentUser();
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('userDtl'))
          ..whereEqualTo('user', currentUser.toPointer())
          ..includeObject([
            'user',
            'gender',
            'interestedIn',
            'profilePicture',
            'profilePictureCollection',
            'archiveMemoryCollection',
          ]);

    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      UserProfile userProfileParse =
          UserProfileParse.from(response.results.first);
      return userProfileParse;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<UserProfile> saveUserProfile(UserProfile userProfile) async {
    ParseResponse response;
    response = await cast<UserProfileParse>(userProfile).toParse(
        skipKeys: ['profilePicture'],
        pointerKeys: ['gender', 'interestedIn']).save();
    if (response.success) {
      userProfile = UserProfileParse.from(response.results.first,
          cacheData: userProfile,
          cacheKeys: ['profilePicture', 'gender', 'interestedIn']);
      return userProfile;
    } else {
      throw ServerException();
    }
  }

  Future<MediaCollectionMapping> saveProfilePicture(
      final MediaCollectionMapping mediaCollectionMapping,
      final UserProfile userProfile) async {
    final List<MediaCollectionMapping> mediaCollectionMappingList =
        await commonRemoteDataSource
            .saveMediaCollectionMappingList([mediaCollectionMapping]);
    ParseObject userProfileParse = ParseObject('userDtl');
    userProfileParse.set('objectId', userProfile.id);
    userProfileParse.set('profilePicture',
        cast<MediaParse>(mediaCollectionMappingList[0].media).pointer);
    userProfileParse.set(
        'profilePictureCollection',
        cast<MediaCollectionParse>(mediaCollectionMappingList[0].collection)
            .pointer);
    ParseResponse response = await userProfileParse.save();
    if (response.success) {
      return mediaCollectionMappingList[0];
    } else {
      throw ServerException();
    }
  }
}
