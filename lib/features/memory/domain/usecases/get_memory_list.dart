import 'package:mood_manager/features/memory/data/repositories/memory_repository.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class GetMemoryList implements UseCase<List<Memory>, NoParams> {
  final MemoryRepository repository;

  GetMemoryList(this.repository);

  @override
  Future<Either<Failure, List<Memory>>> call(NoParams params) async {
    return await repository.getMemoryList();
  }
}
