import 'package:mood_manager/features/memory/data/repositories/memory_repository.dart';
import 'package:mood_manager/features/memory/domain/entities/memory_collection.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class SaveMemoryCollection implements UseCase<MemoryCollection, Params> {
  final MemoryRepository repository;

  SaveMemoryCollection(this.repository);

  @override
  Future<Either<Failure, MemoryCollection>> call(Params params) async {
    return await repository.saveMemoryCollection(params.param);
  }
}
