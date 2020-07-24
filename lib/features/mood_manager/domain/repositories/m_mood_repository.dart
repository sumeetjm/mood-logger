import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/m_mood.dart';

abstract class MMoodRepository {
  Future<Either<Failure, List<MMood>>> getMMoodList();
}
