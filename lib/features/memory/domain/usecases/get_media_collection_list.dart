import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/memory/data/repositories/memory_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class GetMediaCollectionList
    implements UseCase<List<MediaCollection>, NoParams> {
  final MemoryRepository repository;

  GetMediaCollectionList(this.repository);

  @override
  Future<Either<Failure, List<MediaCollection>>> call(NoParams params) async {
    return await repository.getMediaCollectionList(includeAll: true);
  }
}
