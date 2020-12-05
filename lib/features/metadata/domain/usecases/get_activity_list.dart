import 'package:dartz/dartz.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity.dart';
import 'package:mood_manager/features/metadata/domain/repositories/m_activity_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class GetActivityList implements UseCase<List<MActivity>, NoParams> {
  final MActivityRepository repository;

  GetActivityList(this.repository);

  @override
  Future<Either<Failure, List<MActivity>>> call(NoParams params) async {
    return await repository.getMActivityList();
  }
}
