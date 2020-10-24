import 'package:dartz/dartz.dart';
import 'package:mood_manager/features/common/domain/entities/media.dart';
import 'package:mood_manager/features/profile/domain/entities/user_profile.dart';
import 'package:mood_manager/features/profile/domain/repositories/user_profile_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class SaveProfilePicture
    implements UseCase<Media, Params<MapEntry<Media, UserProfile>>> {
  final UserProfileRepository repository;

  SaveProfilePicture(this.repository);

  @override
  Future<Either<Failure, Media>> call(Params params) async {
    return await repository.saveProfilePicture(
        params.param.key, params.param.value);
  }
}
