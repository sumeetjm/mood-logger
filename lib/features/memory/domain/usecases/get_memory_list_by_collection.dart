import 'package:mood_manager/features/memory/data/repositories/memory_repository.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class GetMemoryListByCollection implements UseCase<List<Memory>, Params> {
  final MemoryRepository repository;

  GetMemoryListByCollection(this.repository);

  @override
  Future<Either<Failure, List<Memory>>> call(Params params) async {
    return await repository.getMemoryListByCollection(params.param);
  }
}
