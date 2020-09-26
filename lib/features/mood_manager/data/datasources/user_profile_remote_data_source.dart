import 'dart:developer';

import 'package:mood_manager/features/auth/data/model/parse/user_parse.dart';
import 'package:mood_manager/features/auth/domain/entitles/user.dart';
import 'package:mood_manager/features/mood_manager/data/datasources/metadata_data_source.dart';
import 'package:mood_manager/features/mood_manager/data/models/parse/album_parse.dart';
import 'package:mood_manager/features/mood_manager/data/models/parse/photo_parse.dart';
import 'package:mood_manager/features/mood_manager/data/models/parse/user_profile_parse.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/user_profile.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/album.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/photo.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

import '../../../../core/error/exceptions.dart';

abstract class UserProfileRemoteDataSource {
  Future<UserProfile> getUserProfile(User user);
  Future<UserProfile> getCurrentUserProfile();
  Future<UserProfile> saveUserProfile(UserProfile userProfile);
  Future<List<Photo>> getPhotoListByAlbum(Photo photo);
}

class UserProfileParseDataSource implements UserProfileRemoteDataSource {
  final MetadataRemoteDataSource metadataSource;

  UserProfileParseDataSource({this.metadataSource});

  @override
  Future<UserProfile> getUserProfile(User user) async {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('userDtl'))
          ..whereEqualTo('user', (user as UserParse).toParsePointer())
          ..whereEqualTo('isActive', true);

    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      ParseObject userProfileParse = response.results.first;
      return UserProfileParse.fromParseObject(userProfileParse);
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
            'profilePicture',
            'profilePicture.album',
            'profilePicture.album.albumType',
          ]);

    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      ParseObject userProfileParse = response.results.first;
      return UserProfileParse.fromParseObject(userProfileParse);
    } else {
      throw ServerException();
    }
  }

  @override
  Future<UserProfile> saveUserProfile(UserProfile userProfile) async {
    ParseResponse response;
    if (userProfile.profilePicture != null) {
      response = await (userProfile.profilePicture as PhotoParse)
          ?.toParseObject()
          ?.save();
    }
    if (response == null || response.success) {
      ParseObject profilePictureParse = response?.results?.first;
      ParseObject userProfileParse =
          (userProfile as UserProfileParse).toParseObject();
      userProfileParse.set('profilePicture', profilePictureParse?.toPointer());
      response = await userProfileParse.save();
      if (response.success) {
        userProfileParse = response.results.first;
        profilePictureParse.get('album').set('userDtl', userProfileParse);
        userProfileParse.set('profilePicture', profilePictureParse);
        return UserProfileParse.fromParseObject(userProfileParse);
      } else {
        throw ServerException();
      }
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<Photo>> getPhotoListByAlbum(Photo photo) async {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('photo'))
          ..whereEqualTo('album',
              (photo.album as AlbumParse).baseParsePointer(photo.album))
          ..whereEqualTo('isActive', true)
          ..includeObject([
            'album',
            'album.albumType',
          ])
          ..orderByDescending('createdAt');

    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      List<ParseObject> photoParseArray = response.results;
      final photoList =
          photoParseArray.map((e) => PhotoParse.fromParseObject(e)).toList();
      photoList.remove(photo);
      photoList.insert(0, photo);
      return photoList;
    } else {
      throw ServerException();
    }
  }
}
