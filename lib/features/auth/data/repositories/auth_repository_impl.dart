import 'package:dartz/dartz.dart';
import 'package:mood_manager/core/error/exceptions.dart';
import 'package:mood_manager/core/error/failures.dart';
import 'package:mood_manager/features/auth/data/datasources/auth_data_source.dart';
import 'package:mood_manager/features/auth/domain/entitles/user.dart';
import 'package:mood_manager/features/auth/domain/repositories/auth_repository.dart';
import 'package:mood_manager/features/common/data/datasources/common_remote_data_source.dart';
import '../../../../core/error/exceptions.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;
  final CommonRemoteDataSource commonRemoteDataSource;

  AuthRepositoryImpl({this.dataSource, this.commonRemoteDataSource});

  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      await commonRemoteDataSource.checkConnectivity();
      final user = await dataSource.signInWithGoogle();
      return Right(user);
    } on ServerException {
      return Left(ServerFailure());
    } on NoInternetException {
      return Left(NoInternetFailure());
    }
  }

  Future<Either<Failure, User>> signInWithCredentials(User user) async {
    try {
      await commonRemoteDataSource.checkConnectivity();
      final loggedInUser = await dataSource.signInWithCredentials(
          email: user.email, password: user.password, username: user.userId);
      return Right(loggedInUser);
    } on NoInternetException {
      return Left(NoInternetFailure());
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, void>> signUp(User user) async {
    try {
      await commonRemoteDataSource.checkConnectivity();
      return Right(await dataSource.signUp(
          email: user.email, password: user.password, username: user.userId));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException {
      return Left(ServerFailure());
    } on NoInternetException {
      return Left(NoInternetFailure());
    }
  }

  Future<Either<Failure, void>> signOut() async {
    try {
      return Right(await dataSource.signOut());
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, bool>> isSignedIn() async {
    try {
      final user = await dataSource.isSignedIn();
      return Right(user);
    } on ServerException {
      return Left(ServerFailure());
    } on NoInternetException {
      return Left(NoInternetFailure());
    }
  }

  Future<Either<Failure, User>> getUser() async {
    try {
      final user = await dataSource.getUser();
      return Right(user);
    } on ServerException {
      return Left(ServerFailure());
    } on NoInternetException {
      return Left(NoInternetFailure());
    }
  }

  Future<Either<Failure, User>> signInWithFacebook() async {
    try {
      await commonRemoteDataSource.checkConnectivity();
      final user = await dataSource.signInWithFacebook();
      return Right(user);
    } on ServerException {
      return Left(ServerFailure());
    } on NoInternetException {
      return Left(NoInternetFailure());
    }
  }

  Future<Either<Failure, bool>> isUserExist(User user) async {
    try {
      await commonRemoteDataSource.checkConnectivity();
      final mayBeUserExist = await dataSource.isUserExist(email: user.email);
      return Right(mayBeUserExist);
    } on ServerException {
      return Left(ServerFailure());
    } on NoInternetException {
      return Left(NoInternetFailure());
    }
  }

  Future<Either<Failure, bool>> isUsernameExist(User user) async {
    try {
      await commonRemoteDataSource.checkConnectivity();
      final mayBeUserNameExist =
          await dataSource.isUsernameExist(username: user.userId);
      return Right(mayBeUserNameExist);
    } on ServerException {
      return Left(ServerFailure());
    } on NoInternetException {
      return Left(NoInternetFailure());
    }
  }
}
