import 'package:dartz/dartz.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity.dart';
import 'package:mood_manager/features/metadata/domain/repositories/m_activity_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class SearchActivityList implements UseCase<List<MActivity>, Params> {
  final MActivityRepository repository;

  SearchActivityList(this.repository);

  @override
  Future<Either<Failure, List<MActivity>>> call(Params params) async {
    return await repository.getMActivityListBySearchText(params.param);
  }
}
