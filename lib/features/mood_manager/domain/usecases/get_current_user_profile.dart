import 'package:dartz/dartz.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/user_profile.dart';
import 'package:mood_manager/features/mood_manager/domain/repositories/user_profile_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class GetCurrentUserProfile implements UseCase<UserProfile, NoParams> {
  final UserProfileRepository repository;

  GetCurrentUserProfile(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(NoParams params) async {
    return await repository.getCurrentUserProfile();
  }
}
