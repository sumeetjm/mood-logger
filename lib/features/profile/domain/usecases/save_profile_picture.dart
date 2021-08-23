import 'package:dartz/dartz.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection_mapping.dart';
import 'package:mood_manager/features/profile/domain/repositories/user_profile_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class SaveProfilePicture
    implements UseCase<MediaCollectionMapping, MultiParams> {
  final UserProfileRepository repository;

  SaveProfilePicture(this.repository);

  @override
  Future<Either<Failure, MediaCollectionMapping>> call(
      MultiParams params) async {
    if (params.param[2] != null) {
      return await repository
          .saveProfilePictureAndAddToProfilePictureCollection(
        params.param[2],
      );
    } else {
      return await repository.saveProfilePicture(
        params.param[0],
        params.param[1],
      );
    }
  }
}
