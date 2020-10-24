import 'package:mood_manager/features/metadata/domain/entities/m_mood.dart';
import 'package:mood_manager/features/metadata/domain/repositories/m_mood_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class GetMMoodList implements UseCase<List<MMood>, NoParams> {
  final MMoodRepository repository;

  GetMMoodList(this.repository);

  @override
  Future<Either<Failure, List<MMood>>> call(NoParams params) async {
    return await repository.getMMoodList();
  }
}
