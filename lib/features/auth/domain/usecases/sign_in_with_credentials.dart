import 'package:dartz/dartz.dart';
import 'package:mood_manager/features/auth/domain/entitles/user.dart';
import 'package:mood_manager/features/auth/domain/repositories/auth_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class SignInWithCredentials implements UseCase<User, Params<User>> {
  final AuthRepository repository;

  SignInWithCredentials(this.repository);

  @override
  Future<Either<Failure, User>> call(Params<User> params) async {
    return await repository.signInWithCredentials(params.param);
  }
}
