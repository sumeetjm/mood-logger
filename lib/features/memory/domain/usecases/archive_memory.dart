import 'package:mood_manager/features/memory/data/repositories/memory_repository.dart';
import 'package:mood_manager/features/memory/domain/entities/memory_collection_mapping.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class ArchiveMemory implements UseCase<MemoryCollectionMapping, Params> {
  final MemoryRepository repository;

  ArchiveMemory(this.repository);

  @override
  Future<Either<Failure, MemoryCollectionMapping>> call(Params params) async {
    return await repository.archiveMemory(params.param);
  }
}
