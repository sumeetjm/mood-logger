import 'package:mood_manager/features/mood_manager/domain/entities/t_mood.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

abstract class TMoodRepository {
  Future<Either<Failure, List<TMood>>> getTMoodList();
  Future<Either<Failure, TMood>> saveTMood(TMood tMood);
}
