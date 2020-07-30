import 'package:mood_manager/features/mood_manager/domain/entities/t_activity.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_mood.dart';
import 'package:mood_manager/features/mood_manager/domain/repositories/t_mood_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class SaveTMood
    implements UseCase<TMood, Params<MapEntry<TMood, List<TActivity>>>> {
  final TMoodRepository repository;

  SaveTMood(this.repository);

  @override
  Future<Either<Failure, TMood>> call(
      Params<MapEntry<TMood, List<TActivity>>> params) async {
    return await repository.saveTMood(params.param.key, params.param.value);
  }
}
