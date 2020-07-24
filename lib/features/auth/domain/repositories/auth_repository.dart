import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mood_manager/core/error/failures.dart';
import 'package:mood_manager/features/auth/domain/entitles/user_credenial.dart';

abstract class AuthRepository {
  Future<Either<Failure, FirebaseUser>> signInWithGoogle();
  Future<Either<Failure, FirebaseUser>> signInWithCredentials(
      UserCredential userCredential);
  Future<Either<Failure, void>> signUp(UserCredential userCredential);
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, bool>> isSignedIn();
  Future<Either<Failure, FirebaseUser>> getUser();
}
