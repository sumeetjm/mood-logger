import 'package:mood_manager/features/memory/data/repositories/memory_repository.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class SaveMemory implements UseCase<Memory, MultiParams> {
  final MemoryRepository repository;

  SaveMemory(this.repository);

  @override
  Future<Either<Failure, Memory>> call(MultiParams params) async {
    return await repository.saveMemory(
        params.param[0], params.param[1], params.param[2]);
  }
}
