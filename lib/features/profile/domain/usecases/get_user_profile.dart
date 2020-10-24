import 'package:dartz/dartz.dart';
import 'package:mood_manager/features/profile/domain/entities/user_profile.dart';
import 'package:mood_manager/features/profile/domain/repositories/user_profile_repository.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class GetUserProfile implements UseCase<UserProfile, Params<ParseUser>> {
  final UserProfileRepository repository;

  GetUserProfile(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(Params params) async {
    return await repository.getUserProfile(params.param);
  }
}
