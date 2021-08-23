import 'package:flutter/material.dart';
import 'package:mood_manager/core/error/exceptions.dart';
import 'package:mood_manager/core/error/failures.dart';
import 'package:dartz/dartz.dart' show Either, Right, Left;
import 'package:mood_manager/features/common/data/datasources/common_remote_data_source.dart';
import 'package:mood_manager/features/common/data/models/media_collection_parse.dart';
import 'package:mood_manager/features/common/domain/entities/media.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection_mapping.dart';
import 'package:mood_manager/features/memory/data/datasources/memory_remote_data_source.dart';
import 'package:mood_manager/features/memory/data/models/memory_collection_mapping_parse.dart';
import 'package:mood_manager/features/memory/data/repositories/memory_repository.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:mood_manager/features/memory/domain/entities/memory_collection.dart';
import 'package:mood_manager/features/memory/domain/entities/memory_collection_mapping.dart';
import 'package:mood_manager/features/reminder/domain/entities/task.dart';

class MemoryRepositoryImpl extends MemoryRepository {
  final MemoryRemoteDataSource remoteDataSource;
  final CommonRemoteDataSource commonRemoteDataSource;

  MemoryRepositoryImpl({
    @required this.remoteDataSource,
    @required this.commonRemoteDataSource,
  });

  @override
  Future<Either<Failure, Memory>> saveMemory(Memory memory,
      List<MediaCollectionMapping> mediaCollectionList, Task task) async {
    try {
      await commonRemoteDataSource.checkConnectivity();
      final memorySaved =
          await remoteDataSource.saveMemory(memory, mediaCollectionList, task);
      return Right(memorySaved);
    } on ServerException {
      return Left(ServerFailure());
    } on NoInternetException {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, MemoryCollectionMapping>> archiveMemory(
      Memory memory) async {
    try {
      await commonRemoteDataSource.checkConnectivity();
      final memorySaved = await remoteDataSource.archiveMemory(memory);
      return Right(memorySaved);
    } on ServerException {
      return Left(ServerFailure());
    } on NoInternetException {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, List<Memory>>> getMemoryList() async {
    try {
      await commonRemoteDataSource.checkConnectivity();
      final memoryList = await remoteDataSource.getMemoryList();
      return Right(memoryList);
    } on ServerException {
      return Left(ServerFailure());
    } on NoInternetException {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, MapEntry<MemoryCollection, List<Memory>>>>
      getArchiveMemoryList() async {
    try {
      await commonRemoteDataSource.checkConnectivity();
      final memoryListMapByCollection =
          await remoteDataSource.getCurrentUserArchiveMemoryList();
      return Right(memoryListMapByCollection);
    } on ServerException {
      return Left(ServerFailure());
    } on NoInternetException {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, List<Memory>>> getMemoryListByDate(
      DateTime date) async {
    try {
      await commonRemoteDataSource.checkConnectivity();
      final memoryList = await remoteDataSource.getMemoryListByDate(date);
      return Right(memoryList);
    } on ServerException {
      return Left(ServerFailure());
    } on NoInternetException {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, List<MemoryCollection>>>
      getMemoryCollectionList() async {
    try {
      await commonRemoteDataSource.checkConnectivity();
      final memoryCollectionList =
          await remoteDataSource.getMemoryCollectionList();
      return Right(memoryCollectionList);
    } on ServerException {
      return Left(ServerFailure());
    } on NoInternetException {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, MemoryCollectionMappingParse>> addMemoryToCollection(
      MemoryCollectionMapping memoryCollectionMapping) async {
    try {
      await commonRemoteDataSource.checkConnectivity();
      if (memoryCollectionMapping.isActive) {
        final memoryCollectionMappingSaved = await remoteDataSource
            .saveMemoryCollectionMapping(memoryCollectionMapping);
        return Right(memoryCollectionMappingSaved);
      } else {
        final memoryCollectionMappingSaved = await remoteDataSource
            .deactivateMemoryCollectionMapping(memoryCollectionMapping);
        return Right(memoryCollectionMappingSaved);
      }
    } on NoInternetException {
      return Left(NoInternetFailure());
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Memory>>> getMemoryListByCollection(
      MemoryCollection memoryCollection) async {
    try {
      await commonRemoteDataSource.checkConnectivity();
      final memoryList =
          await remoteDataSource.getMemoryListByCollection(memoryCollection);
      return Right(memoryList);
    } on ServerException {
      return Left(ServerFailure());
    } on NoInternetException {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, List<MediaCollection>>> getMediaCollectionList(
      {bool includeAll, bool skipEmpty, String mediaType}) async {
    try {
      await commonRemoteDataSource.checkConnectivity();
      final mediaCollectionList = await remoteDataSource
          .getMediaCollectionListByModuleList(['PROFILE_PICTURE', 'CUSTOM'],
              mediaType: mediaType, skipEmpty: skipEmpty);
      mediaCollectionList.insert(
          0,
          MediaCollectionParse(
            name: 'All Media',
            code: 'ALL',
            mediaCount: await commonRemoteDataSource.getTotalNoOfMedia(),
            imageCount: await commonRemoteDataSource.getTotalNoOfPhotos(),
            videoCount: await commonRemoteDataSource.getTotalNoOfVideos(),
            //mediaType: 'PHOTO',
          ));
      if (includeAll ?? false) {}
      return Right(mediaCollectionList);
    } on ServerException {
      return Left(ServerFailure());
    } on NoInternetException {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, List<Memory>>> getMemoryListByMedia(
      Media media) async {
    try {
      await commonRemoteDataSource.checkConnectivity();
      final memoryList = await remoteDataSource.getMemoryListByMedia(media);
      return Right(memoryList);
    } on ServerException {
      return Left(ServerFailure());
    } on NoInternetException {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, List<Memory>>> getMemory(String id) async {
    try {
      await commonRemoteDataSource.checkConnectivity();
      final memoryList = await remoteDataSource.getMemory(id);
      return Right(memoryList);
    } on ServerException {
      return Left(ServerFailure());
    } on NoInternetException {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, MemoryCollection>> saveMemoryCollection(
      MemoryCollection memoryCollection) async {
    try {
      await commonRemoteDataSource.checkConnectivity();
      final memorySaved =
          await remoteDataSource.saveMemoryCollection(memoryCollection);
      return Right(memorySaved);
    } on ServerException {
      return Left(ServerFailure());
    } on NoInternetException {
      return Left(NoInternetFailure());
    }
  }
}
