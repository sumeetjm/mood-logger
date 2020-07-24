import 'package:dartz/dartz.dart';
import 'package:mood_manager/features/mood_manager/data/models/m_activity_model.dart';
import 'package:mood_manager/features/mood_manager/domain/repositories/m_activity_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class GetMActivityList
    implements UseCase<Map<String, List<MActivityModel>>, NoParams> {
  final MActivityRepository repository;

  GetMActivityList(this.repository);

  @override
  Future<Either<Failure, Map<String, List<MActivityModel>>>> call(
      NoParams params) async {
    return await repository.getMActivityListGroupdByType();
  }
}
