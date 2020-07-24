import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mood_manager/features/auth/domain/entitles/user_credenial.dart';
import 'package:mood_manager/features/auth/domain/repositories/auth_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class SignInWithCredentials
    implements UseCase<FirebaseUser, Params<UserCredential>> {
  final AuthRepository repository;

  SignInWithCredentials(this.repository);

  @override
  Future<Either<Failure, FirebaseUser>> call(
      Params<UserCredential> params) async {
    return await repository.signInWithCredentials(params.param);
  }
}
