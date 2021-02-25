import 'package:flutter/material.dart';
import 'package:mood_manager/core/error/exceptions.dart';
import 'package:mood_manager/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:mood_manager/core/network/network_info.dart';
import 'package:mood_manager/features/common/data/models/media_collection_parse.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection_mapping.dart';
import 'package:mood_manager/features/memory/data/datasources/memory_remote_data_source.dart';
import 'package:mood_manager/features/memory/data/models/memory_collection_mapping_parse.dart';
import 'package:mood_manager/features/memory/data/repositories/memory_repository.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:mood_manager/features/memory/domain/entities/memory_collection.dart';
import 'package:mood_manager/features/memory/domain/entities/memory_collection_mapping.dart';

class MemoryRepositoryImpl extends MemoryRepository {
  final MemoryRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  MemoryRepositoryImpl({
    @required this.remoteDataSource,
    @required this.networkInfo,
  });

  @override
  Future<Either<Failure, Memory>> saveMemory(
      Memory memory, List<MediaCollectionMapping> mediaCollectionList) async {
    if (await networkInfo.isConnected) {
      try {
        final memorySaved =
            await remoteDataSource.saveMemory(memory, mediaCollectionList);
        return Right(memorySaved);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Memory>> archiveMemory(Memory memory) async {
    if (await networkInfo.isConnected) {
      try {
        final memorySaved = await remoteDataSource.archiveMemory(memory);
        return Right(memorySaved);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Memory>>> getMemoryList() async {
    if (await networkInfo.isConnected) {
      try {
        final memoryList = await remoteDataSource.getMemoryList();
        return Right(memoryList);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, MapEntry<MemoryCollection, List<Memory>>>>
      getArchiveMemoryList() async {
    if (await networkInfo.isConnected) {
      try {
        final memoryListMapByCollection =
            await remoteDataSource.getCurrentUserArchiveMemoryList();
        return Right(memoryListMapByCollection);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Memory>>> getMemoryListByDate(
      DateTime date) async {
    if (await networkInfo.isConnected) {
      try {
        final memoryList = await remoteDataSource.getMemoryListByDate(date);
        return Right(memoryList);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<MemoryCollection>>>
      getMemoryCollectionList() async {
    if (await networkInfo.isConnected) {
      try {
        final memoryCollectionList =
            await remoteDataSource.getMemoryCollectionList();
        return Right(memoryCollectionList);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, MemoryCollectionMappingParse>> addMemoryToCollection(
      MemoryCollectionMapping memoryCollectionMapping) async {
    if (await networkInfo.isConnected) {
      try {
        if (memoryCollectionMapping.isActive) {
          final memoryCollectionMappingSaved = await remoteDataSource
              .saveMemoryCollectionMapping(memoryCollectionMapping);
          return Right(memoryCollectionMappingSaved);
        } else {
          final memoryCollectionMappingSaved = await remoteDataSource
              .deactivateMemoryCollectionMapping(memoryCollectionMapping);
          return Right(memoryCollectionMappingSaved);
        }
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Memory>>> getMemoryListByCollection(
      MemoryCollection memoryCollection) async {
    if (await networkInfo.isConnected) {
      try {
        final memoryList =
            await remoteDataSource.getMemoryListByCollection(memoryCollection);
        return Right(memoryList);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<MediaCollection>>> getMediaCollectionList(
      {bool includeAll}) async {
    if (await networkInfo.isConnected) {
      try {
        final mediaCollectionList = await remoteDataSource
            .getMediaCollectionListByModuleList(['PROFILE_PICTURE', 'CUSTOM']);
        mediaCollectionList.insert(
            0,
            MediaCollectionParse(
              name: 'All Media',
              code: 'ALL',
              //mediaType: 'PHOTO',
            ));
        if (includeAll ?? false) {}
        return Right(mediaCollectionList);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(ServerFailure());
    }
  }
}
