import 'package:mood_manager/features/memory/data/repositories/memory_repository.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class GetMemoryListByDate implements UseCase<List<Memory>, Params<DateTime>> {
  final MemoryRepository repository;

  GetMemoryListByDate(this.repository);

  @override
  Future<Either<Failure, List<Memory>>> call(Params params) async {
    return await repository.getMemoryListByDate(params.param);
  }
}
