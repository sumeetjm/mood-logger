import 'package:mood_manager/features/auth/domain/entitles/user.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_mood.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/user_profile.dart';
import 'package:mood_manager/features/mood_manager/domain/repositories/t_mood_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:mood_manager/features/mood_manager/domain/repositories/user_profile_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class GetUserProfile implements UseCase<UserProfile, Params<User>> {
  final UserProfileRepository repository;

  GetUserProfile(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(Params params) async {
    return await repository.getUserProfile(params.param);
  }
}
