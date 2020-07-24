import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mood_manager/core/error/exceptions.dart';
import 'package:mood_manager/core/error/failures.dart';
import 'package:mood_manager/core/network/network_info.dart';
import 'package:mood_manager/features/auth/data/datasources/auth_data_source.dart';
import 'package:mood_manager/features/auth/domain/entitles/user_credenial.dart';
import 'package:mood_manager/features/auth/domain/repositories/auth_repository.dart';
import '../../../../core/error/exceptions.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({AuthDataSource dataSource, NetworkInfo networkInfo})
      : assert(dataSource != null),
        assert(networkInfo != null),
        this.dataSource = dataSource,
        this.networkInfo = networkInfo;

  Future<Either<Failure, FirebaseUser>> signInWithGoogle() async {
    try {
      final user = await dataSource.signInWithGoogle();
      return Right(user);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, FirebaseUser>> signInWithCredentials(
      UserCredential userCredential) async {
    try {
      final user = await dataSource.signInWithCredentials(
          email: userCredential.email, password: userCredential.password);
      return Right(user);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, void>> signUp(UserCredential userCredential) async {
    try {
      return Right(await dataSource.signUp(
          email: userCredential.email, password: userCredential.password));
    } on ServerException {
      return Left(ServerFailure());
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
    }
  }

  Future<Either<Failure, FirebaseUser>> getUser() async {
    try {
      final user = await dataSource.getUser();
      return Right(user);
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
