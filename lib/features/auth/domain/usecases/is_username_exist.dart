import 'package:dartz/dartz.dart';
import 'package:mood_manager/features/auth/domain/entitles/user.dart';
import 'package:mood_manager/features/auth/domain/repositories/auth_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class IsUsernameExist implements UseCase<bool, Params<User>> {
  final AuthRepository repository;

  IsUsernameExist(this.repository);

  @override
  Future<Either<Failure, bool>> call(Params<User> params) async {
    return await repository.isUsernameExist(params.param);
  }
}
