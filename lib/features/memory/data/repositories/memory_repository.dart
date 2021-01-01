import 'package:dartz/dartz.dart';
import 'package:mood_manager/core/error/failures.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';

abstract class MemoryRepository {
  Future<Either<Failure, Memory>> saveMemory(
      Memory memory, List<MediaCollection> mediaCollectionList);

  Future<Either<Failure, List<Memory>>> getMemoryList();
  Future<Either<Failure, List<Memory>>> getMemoryListByDate(DateTime date);
}
