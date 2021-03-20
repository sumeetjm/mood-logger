import 'package:dartz/dartz.dart';
import 'package:mood_manager/features/auth/domain/entitles/user.dart';
import 'package:mood_manager/features/auth/domain/repositories/auth_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class IsUserExist implements UseCase<bool, Params<User>> {
  final AuthRepository repository;

  IsUserExist(this.repository);

  @override
  Future<Either<Failure, bool>> call(Params<User> params) async {
    return await repository.isUserExist(params.param);
  }
}
