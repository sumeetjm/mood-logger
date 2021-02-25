import 'package:mood_manager/features/memory/data/repositories/memory_repository.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:dartz/dartz.dart';
import 'package:mood_manager/features/memory/domain/entities/memory_collection.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class GetArchiveMemoryList
    implements UseCase<MapEntry<MemoryCollection, List<Memory>>, NoParams> {
  final MemoryRepository repository;

  GetArchiveMemoryList(this.repository);

  @override
  Future<Either<Failure, MapEntry<MemoryCollection, List<Memory>>>> call(
      NoParams params) async {
    return await repository.getArchiveMemoryList();
  }
}
