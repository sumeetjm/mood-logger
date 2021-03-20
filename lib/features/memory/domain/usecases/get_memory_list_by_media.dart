import 'package:mood_manager/features/common/domain/entities/media.dart';
import 'package:mood_manager/features/memory/data/repositories/memory_repository.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class GetMemoryListByMedia implements UseCase<List<Memory>, Params<Media>> {
  final MemoryRepository repository;

  GetMemoryListByMedia(this.repository);

  @override
  Future<Either<Failure, List<Memory>>> call(Params params) async {
    return await repository.getMemoryListByMedia(params.param);
  }
}
