import 'package:dartz/dartz.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity_type.dart';
import 'package:mood_manager/features/metadata/domain/repositories/m_activity_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class GetActivityTypeList implements UseCase<List<MActivityType>, NoParams> {
  final MActivityRepository repository;

  GetActivityTypeList(this.repository);

  @override
  Future<Either<Failure, List<MActivityType>>> call(NoParams params) async {
    return await repository.getMActivityTypeList();
  }
}
