import 'package:dartz/dartz.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_activity.dart';
import 'package:mood_manager/features/mood_manager/domain/repositories/m_activity_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class GetMActivityList implements UseCase<List<MActivity>, NoParams> {
  final MActivityRepository repository;

  GetMActivityList(this.repository);

  @override
  Future<Either<Failure, List<MActivity>>> call(NoParams params) async {
    return await repository.getMActivityList();
  }
}
