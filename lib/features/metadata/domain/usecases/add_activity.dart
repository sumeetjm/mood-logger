import 'package:dartz/dartz.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity.dart';
import 'package:mood_manager/features/metadata/domain/repositories/m_activity_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class AddActivity implements UseCase<MActivity, Params> {
  final MActivityRepository repository;

  AddActivity(this.repository);

  @override
  Future<Either<Failure, MActivity>> call(Params params) async {
    return await repository.addMActivity(params.param);
  }
}
