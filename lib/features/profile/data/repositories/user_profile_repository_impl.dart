import 'package:mood_manager/features/auth/data/datasources/auth_data_source.dart';
import 'package:mood_manager/features/common/data/datasources/common_remote_data_source.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection_mapping.dart';
import 'package:mood_manager/features/profile/data/datasources/user_profile_remote_data_source.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:mood_manager/features/common/domain/entities/media.dart';
import 'package:mood_manager/features/profile/domain/entities/user_profile.dart';
import 'package:mood_manager/features/profile/domain/repositories/user_profile_repository.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource remoteDataSource;
  final AuthDataSource authRemoteDataSource;
  final CommonRemoteDataSource commonRemoteDataSource;

  UserProfileRepositoryImpl(
      {@required this.remoteDataSource,
      @required this.authRemoteDataSource,
      @required this.commonRemoteDataSource});

  @override
  Future<Either<Failure, UserProfile>> getCurrentUserProfile() async {
    try {
      await commonRemoteDataSource.checkConnectivity();
      final userProfile = await remoteDataSource.getCurrentUserProfile();
      return Right(userProfile);
    } on ServerException {
      return Left(ServerFailure());
    } on NoInternetException {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, UserProfile>> getUserProfile(ParseUser user) async {
    try {
      await commonRemoteDataSource.checkConnectivity();
      final userProfile = await remoteDataSource.getUserProfile(user);
      return Right(userProfile);
    } on ServerException {
      return Left(ServerFailure());
    } on NoInternetException {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, UserProfile>> saveUserProfile(
      UserProfile userProfile) async {
    try {
      await commonRemoteDataSource.checkConnectivity();
      final userProfileSaved =
          await remoteDataSource.saveUserProfile(userProfile);
      return Right(userProfileSaved);
    } on ServerException {
      return Left(ServerFailure());
    } on NoInternetException {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, MediaCollectionMapping>> saveProfilePicture(
      MediaCollectionMapping photoMediaCollection,
      UserProfile userProfile) async {
    try {
      await commonRemoteDataSource.checkConnectivity();
      final photoSaved = await remoteDataSource.saveProfilePicture(
          photoMediaCollection, userProfile);
      return Right(photoSaved);
    } on ServerException {
      return Left(ServerFailure());
    } on NoInternetException {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, MediaCollectionMapping>>
      saveProfilePictureAndAddToProfilePictureCollection(Media media) async {
    try {
      await commonRemoteDataSource.checkConnectivity();
      final photoSaved = await remoteDataSource
          .saveProfilePictureAndAddToProfilePictureCollection(media);
      return Right(photoSaved);
    } on ServerException {
      return Left(ServerFailure());
    } on NoInternetException {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, String>> linkWithSocial(String social) async {
    try {
      await commonRemoteDataSource.checkConnectivity();
      if (social == 'google') {
        await authRemoteDataSource.linkWithGoogle();
      } else if (social == 'facebook') {
        await authRemoteDataSource.linkWithFacebook();
      }
      return Right(social);
    } on ServerException {
      return Left(ServerFailure());
    } on NoInternetException {
      return Left(NoInternetFailure());
    }
  }
}
