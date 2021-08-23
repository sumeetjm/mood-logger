import 'package:mood_manager/features/memory/data/repositories/memory_repository.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class GetSingleMemory implements UseCase<List<Memory>, Params<String>> {
  final MemoryRepository repository;

  GetSingleMemory(this.repository);

  @override
  Future<Either<Failure, List<Memory>>> call(Params params) async {
    return await repository.getMemory(params.param);
  }
}
