import 'package:dartz/dartz.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity_type.dart';

import '../../../../core/error/failures.dart';

abstract class MActivityRepository {
  Future<Either<Failure, List<MActivity>>> getMActivityList();
  Future<Either<Failure, List<MActivity>>> getMActivityListBySearchText(
      String searchText);
  Future<Either<Failure, List<MActivityType>>> getMActivityTypeList();
  Future<Either<Failure, MActivity>> addMActivity(MActivity toBeAddedMActivity);
}
