import 'package:mood_manager/features/auth/data/datasources/auth_data_source.dart';
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
import '../../../../core/network/network_info.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource remoteDataSource;
  final AuthDataSource authRemoteDataSource;
  final NetworkInfo networkInfo;

  UserProfileRepositoryImpl({
    @required this.remoteDataSource,
    @required this.networkInfo,
    @required this.authRemoteDataSource,
  });

  @override
  Future<Either<Failure, UserProfile>> getCurrentUserProfile() async {
    if (await networkInfo.isConnected) {
      try {
        final userProfile = await remoteDataSource.getCurrentUserProfile();
        return Right(userProfile);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserProfile>> getUserProfile(ParseUser user) async {
    if (await networkInfo.isConnected) {
      try {
        final userProfile = await remoteDataSource.getUserProfile(user);
        return Right(userProfile);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserProfile>> saveUserProfile(
      UserProfile userProfile) async {
    if (await networkInfo.isConnected) {
      try {
        final userProfileSaved =
            await remoteDataSource.saveUserProfile(userProfile);
        return Right(userProfileSaved);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Media>> saveProfilePicture(
      MediaCollectionMapping photoMediaCollection,
      UserProfile userProfile) async {
    if (await networkInfo.isConnected) {
      try {
        final photoSaved = await remoteDataSource.saveProfilePicture(
            photoMediaCollection, userProfile);
        return Right(photoSaved.media);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, String>> linkWithSocial(String social) async {
    if (await networkInfo.isConnected) {
      try {
        if (social == 'google') {
          await authRemoteDataSource.linkWithGoogle();
        } else if (social == 'facebook') {
          await authRemoteDataSource.linkWithFacebook();
        }
        return Right(social);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(ServerFailure());
    }
  }
}
