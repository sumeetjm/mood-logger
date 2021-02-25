import 'package:dartz/dartz.dart';
import 'package:mood_manager/core/error/failures.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection_mapping.dart';
import 'package:mood_manager/features/memory/data/models/memory_collection_mapping_parse.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:mood_manager/features/memory/domain/entities/memory_collection.dart';
import 'package:mood_manager/features/memory/domain/entities/memory_collection_mapping.dart';

abstract class MemoryRepository {
  Future<Either<Failure, Memory>> saveMemory(
      Memory memory, List<MediaCollectionMapping> mediaCollectionList);
  Future<Either<Failure, Memory>> archiveMemory(Memory memory);

  Future<Either<Failure, List<Memory>>> getMemoryList();
  Future<Either<Failure, MapEntry<MemoryCollection, List<Memory>>>>
      getArchiveMemoryList();
  Future<Either<Failure, List<Memory>>> getMemoryListByCollection(
      MemoryCollection memoryCollection);
  Future<Either<Failure, List<Memory>>> getMemoryListByDate(DateTime date);
  Future<Either<Failure, List<MemoryCollection>>> getMemoryCollectionList();
  Future<Either<Failure, MemoryCollectionMapping>> addMemoryToCollection(
      MemoryCollectionMapping memoryCollectionMapping);
  Future<Either<Failure, List<MediaCollection>>> getMediaCollectionList(
      {bool includeAll});
}
