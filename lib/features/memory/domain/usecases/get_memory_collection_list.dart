import 'package:mood_manager/features/memory/data/repositories/memory_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:mood_manager/features/memory/domain/entities/memory_collection.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class GetMemoryCollectionList
    implements UseCase<List<MemoryCollection>, NoParams> {
  final MemoryRepository repository;

  GetMemoryCollectionList(this.repository);

  @override
  Future<Either<Failure, List<MemoryCollection>>> call(NoParams params) async {
    return await repository.getMemoryCollectionList();
  }
}
