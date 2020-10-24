import 'package:dartz/dartz.dart';
import 'package:mood_manager/features/profile/domain/entities/user_profile.dart';
import 'package:mood_manager/features/profile/domain/repositories/user_profile_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class SaveUserProfile implements UseCase<UserProfile, Params<UserProfile>> {
  final UserProfileRepository repository;

  SaveUserProfile(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(Params params) async {
    return await repository.saveUserProfile(params.param);
  }
}
