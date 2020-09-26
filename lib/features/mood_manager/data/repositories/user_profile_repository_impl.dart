import 'package:mood_manager/features/auth/domain/entitles/user.dart';
import 'package:mood_manager/features/mood_manager/data/datasources/m_mood_remote_data_source.dart';
import 'package:mood_manager/features/mood_manager/data/datasources/user_profile_remote_data_source.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/photo.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/album.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/user_profile.dart';
import 'package:mood_manager/features/mood_manager/domain/repositories/m_mood_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:mood_manager/features/mood_manager/domain/repositories/user_profile_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/m_mood.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  UserProfileRepositoryImpl({
    @required this.remoteDataSource,
    @required this.networkInfo,
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
  Future<Either<Failure, UserProfile>> getUserProfile(User user) async {
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
}
