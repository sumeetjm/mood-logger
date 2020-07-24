import 'package:dartz/dartz.dart';
import 'package:mood_manager/features/auth/domain/entitles/user_credenial.dart';
import 'package:mood_manager/features/auth/domain/repositories/auth_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class SignUp implements UseCase<void, Params<UserCredential>> {
  final AuthRepository repository;

  SignUp(this.repository);

  @override
  Future<Either<Failure, void>> call(Params<UserCredential> params) async {
    return await repository.signUp(params.param);
  }
}
