import 'package:mood_manager/features/mood_manager/domain/entities/t_mood.dart';
import 'package:mood_manager/features/mood_manager/domain/repositories/t_mood_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class GetTMoodList implements UseCase<List<TMood>, NoParams> {
  final TMoodRepository repository;

  GetTMoodList(this.repository);

  @override
  Future<Either<Failure, List<TMood>>> call(NoParams params) async {
    return await repository.getTMoodList();
  }
}
