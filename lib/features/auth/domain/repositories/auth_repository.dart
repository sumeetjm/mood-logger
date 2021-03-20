import 'package:dartz/dartz.dart';
import 'package:mood_manager/core/error/failures.dart';
import 'package:mood_manager/features/auth/domain/entitles/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signInWithGoogle();
  Future<Either<Failure, User>> signInWithCredentials(User user);
  Future<Either<Failure, void>> signUp(User user);
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, bool>> isSignedIn();
  Future<Either<Failure, User>> getUser();
  Future<Either<Failure, User>> signInWithFacebook();
  Future<Either<Failure, bool>> isUserExist(User user);
  Future<Either<Failure, bool>> isUsernameExist(User user);
}
