import 'package:dartz/dartz.dart';
import 'package:mood_manager/features/profile/domain/repositories/user_profile_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class LinkWithSocial implements UseCase<String, Params<String>> {
  final UserProfileRepository repository;

  LinkWithSocial(this.repository);

  @override
  Future<Either<Failure, String>> call(Params params) async {
    return await repository.linkWithSocial(params.param);
  }
}
