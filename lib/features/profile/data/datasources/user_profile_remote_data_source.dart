import 'package:dartz/dartz.dart' show cast;
import 'package:mood_manager/core/constants/app_constants.dart';
import 'package:mood_manager/features/common/data/datasources/common_remote_data_source.dart';
import 'package:mood_manager/features/common/data/models/media_collection_mapping_parse.dart';
import 'package:mood_manager/features/common/data/models/media_collection_parse.dart';
import 'package:mood_manager/features/common/data/models/media_parse.dart';
import 'package:mood_manager/features/common/domain/entities/media.dart';
import 'package:mood_manager/features/profile/data/models/user_profile_parse.dart';
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
  Future<MediaCollectionMapping>
      saveProfilePictureAndAddToProfilePictureCollection(final Media media);
  Future<void> setUser(ParseObject parseObject) async {
    if (parseObject != null) {
      parseObject.set('user', await ParseUser.currentUser());
    }
  }
}

class UserProfileParseDataSource extends UserProfileRemoteDataSource {
  final CommonRemoteDataSource commonRemoteDataSource;

  UserProfileParseDataSource({
    this.commonRemoteDataSource,
  });
  @override
  Future<UserProfile> getUserProfile(ParseUser user) async {
    /*final userProfileBox = await Hive.openBox<UserProfile>('userProfile');
    if (userProfileBox.get(user.objectId) == null) {*/
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('userDtl'))
          ..whereEqualTo('user', user.toPointer())
          ..whereEqualTo('isActive', true);

    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      UserProfile userProfileParse =
          UserProfileParse.from(response.results.first);
      //userProfileBox.put(user.objectId, userProfileParse);
      return userProfileParse;
    } else {
      throw ServerException();
    }
    /* else {
      final userProfile = userProfileBox.get(user.objectId);
      userProfile.user = user;
      return userProfile;
    }*/
  }

  @override
  Future<UserProfile> getCurrentUserProfile() async {
    /*final userProfileBox = await Hive.openBox<UserProfile>('userProfile');*/
    ParseUser currentUser = await ParseUser.currentUser();
    /* if (userProfileBox.get(currentUser.objectId) == null) {*/
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
          UserProfileParse.from(response.results?.first);
      // userProfileBox.put(currentUser.objectId, userProfileParse);
      return userProfileParse;
    } else {
      throw ServerException();
    }
    /*} else {
      final userProfile = userProfileBox.get(currentUser.objectId);
      userProfile.user = currentUser;
      return userProfile;
    }*/
  }

  @override
  Future<UserProfile> saveUserProfile(UserProfile userProfile) async {
    //final userProfileBox = await Hive.openBox<UserProfile>('userProfile');
    ParseResponse response;
    final userProfileParse = cast<UserProfileParse>(userProfile).toParse(
        skipKeys: ['profilePicture'], pointerKeys: ['gender', 'interestedIn']);
    setUser(userProfileParse.get('archiveMemoryCollection'));
    response = await userProfileParse.save();
    if (response.success) {
      userProfile = UserProfileParse.from(response.results.first,
          cacheData: userProfile,
          cacheKeys: ['profilePicture', 'gender', 'interestedIn']);
      //userProfileBox.put(userProfile.user.objectId, userProfile);
      return userProfile;
    } else {
      throw ServerException();
    }
  }

  Future<MediaCollectionMapping> saveProfilePicture(
      final MediaCollectionMapping mediaCollectionMapping,
      final UserProfile userProfile,
      {bool skipAddToCollection = false}) async {
    //final userProfileBox = await Hive.openBox<UserProfile>('userProfile');
    if (mediaCollectionMapping == null) {
      ParseObject userProfileParse = ParseObject('userDtl');
      userProfileParse.set('objectId', userProfile.id);
      userProfileParse.set('profilePicture',
          cast<MediaParse>(AppConstants.DEFAULT_PROFILE_MEDIA).pointer);
      ParseResponse response = await userProfileParse.save();
      if (response.success) {
        return mediaCollectionMapping;
      } else {
        throw ServerException();
      }
    } else {
      var profilePistureMapping;
      if (skipAddToCollection) {
        profilePistureMapping = mediaCollectionMapping;
      } else {
        final List<MediaCollectionMapping> mediaCollectionMappingList =
            await commonRemoteDataSource
                .saveMediaCollectionMappingList([mediaCollectionMapping]);
        profilePistureMapping = mediaCollectionMappingList[0];
      }
      ParseObject userProfileParse = ParseObject('userDtl');
      userProfileParse.set('objectId', userProfile.id);
      userProfileParse.set('profilePicture',
          cast<MediaParse>(profilePistureMapping.media).pointer);
      userProfileParse.set('profilePictureCollection',
          cast<MediaCollectionParse>(profilePistureMapping.collection).pointer);
      //var userProfileFromBox = userProfileBox.get(userProfile.user.objectId);
      /*userProfileBox.put(
        userProfile.user.objectId,
        UserProfileParse.fromProfilePic(
            userProfileFromBox,
            cast<MediaParse>(mediaCollectionMappingList[0].media),
            cast<MediaCollectionParse>(
                mediaCollectionMappingList[0].collection)));*/
      ParseResponse response = await userProfileParse.save();
      if (response.success) {
        return profilePistureMapping;
      } else {
        throw ServerException();
      }
    }
  }

  Future<MediaCollectionMapping>
      saveProfilePictureAndAddToProfilePictureCollection(
          final Media media) async {
    final userProfile = await getCurrentUserProfile();
    final mediaCollectionMappingList =
        await commonRemoteDataSource.getMediaCollectionMappingByCollection(
            userProfile.profilePictureCollection);
    final mediaCollectionMapping = await saveProfilePicture(
        MediaCollectionMappingParse(
          collection: userProfile.profilePictureCollection,
          media: media,
        ),
        userProfile,
        skipAddToCollection: mediaCollectionMappingList
            .any((element) => element.media == media));
    return mediaCollectionMapping;
  }
}
