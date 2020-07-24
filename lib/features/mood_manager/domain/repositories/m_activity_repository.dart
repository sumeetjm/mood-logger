import 'package:dartz/dartz.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_activity.dart';

import '../../../../core/error/failures.dart';

abstract class MActivityRepository {
  Future<Either<Failure, Map<String, List<MActivity>>>>
      getMActivityListGroupdByType();
}
