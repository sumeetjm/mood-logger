import 'package:dartz/dartz.dart' show cast;
import 'package:mood_manager/features/common/data/models/parse_mixin.dart';
import 'package:mood_manager/features/common/data/models/collection_parse.dart';
import 'package:mood_manager/features/common/data/models/media_collection_parse.dart';
import 'package:mood_manager/features/common/data/models/photo_parse.dart';
import 'package:mood_manager/features/profile/data/models/user_profile_parse.dart';
import 'package:mood_manager/features/common/domain/entities/collection.dart';
import 'package:mood_manager/features/common/domain/entities/media.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/profile/domain/entities/user_profile.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

import '../../../../core/error/exceptions.dart';

abstract class UserProfileRemoteDataSource {
  Future<UserProfile> getUserProfile(ParseUser user);
  Future<UserProfile> getCurrentUserProfile();
  Future<UserProfile> saveUserProfile(UserProfile userProfile);
  Future<List<MediaCollection>> getMediaCollectionByMedia(
      Media media, String module, ParseUser user);
  Future<List<MediaCollection>> getMediaCollectionByCollection(
      Collection collection);
  Future<MediaCollection> saveMediaCollection(
      final MediaCollection mediaCollection);
  Future<MediaCollection> saveProfilePicture(
      final Media media, final UserProfile userProfile);
}

class UserProfileParseDataSource implements UserProfileRemoteDataSource {
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

  @override
  Future<List<MediaCollection>> getMediaCollectionByMedia(
      Media media, String module, ParseUser user) async {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('collection'))
          ..whereEqualTo('module', module)
          ..whereEqualTo('user', user.toPointer())
          ..whereEqualTo('isActive', true);

    final ParseResponse response = await queryBuilder.query();

    if (response.success) {
      Collection collection = CollectionParse.from(response.results.first);
      return getMediaCollectionByCollection(collection);
    }
    throw ServerException();
  }

  @override
  Future<List<MediaCollection>> getMediaCollectionByCollection(
      Collection collection,
      {Media priorityMedia}) async {
    QueryBuilder<ParseObject> queryBuilder = QueryBuilder<ParseObject>(
        ParseObject('mediaCollection'))
      ..whereEqualTo('collection', cast<CollectionParse>(collection).pointer)
      ..whereEqualTo('isActive', true)
      ..includeObject(['media, collection'])
      ..orderByDescending('createdAt');

    final ParseResponse response = await queryBuilder.query();

    if (response.success) {
      final List<MediaCollection> mediaCollectionList =
          ParseMixin.listFrom<MediaCollection>(
              response.results, MediaCollectionParse.from);

      final priorityMediaCollection = mediaCollectionList
          .firstWhere((element) => element.media == priorityMedia);
      mediaCollectionList
          .removeWhere((element) => element.media == priorityMedia);
      mediaCollectionList.insert(0, priorityMediaCollection);
      return mediaCollectionList;
    } else {
      throw ServerException();
    }
  }

  Future<MediaCollection> saveMediaCollection(
      final MediaCollection mediaCollection) async {
    ParseResponse response = await cast<MediaCollectionParse>(mediaCollection)
        .toParse(pointerKeys: ['collection', 'media']).save();
    if (response.success) {
      return MediaCollectionParse.from(response.results.first,
          cacheData: mediaCollection, cacheKeys: ['collection', 'media']);
    } else {
      throw ServerException();
    }
  }

  Future<MediaCollection> saveProfilePicture(
      final Media media, final UserProfile userProfile) async {
    final MediaCollection mediaCollection = MediaCollectionParse(
        collection: userProfile.profilePictureCollection,
        media: await saveMedia(media));
    ParseObject userProfileParse = ParseObject('userDtl');
    userProfileParse.set('objectId', userProfile.id);
    userProfileParse.set(
        'profilePicture', cast<MediaParse>(mediaCollection.media).pointer);
    ParseResponse response = await userProfileParse.save();
    if (response.success) {
      return await saveMediaCollection(mediaCollection);
    } else {
      throw ServerException();
    }
  }

  Future<Media> saveMedia(Media media) async {
    final ParseResponse response =
        await cast<MediaParse>(media).toParse().save();
    if (response.success) {
      return MediaParse.from(response.results.first);
    } else {
      throw ServerException();
    }
  }

  Future<Collection> saveCollection(Collection collection) async {
    final ParseResponse response =
        await cast<CollectionParse>(collection).toParse().save();
    if (response.success) {
      return CollectionParse.from(response.results.first);
    } else {
      throw ServerException();
    }
  }
}
