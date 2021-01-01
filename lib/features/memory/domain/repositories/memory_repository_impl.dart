import 'package:flutter/material.dart';
import 'package:mood_manager/core/error/exceptions.dart';
import 'package:mood_manager/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:mood_manager/core/network/network_info.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/memory/data/datasources/memory_remote_data_source.dart';
import 'package:mood_manager/features/memory/data/repositories/memory_repository.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:mood_manager/features/memory/domain/usecases/get_memory_list.dart';

class MemoryRepositoryImpl extends MemoryRepository {
  final MemoryRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  MemoryRepositoryImpl({
    @required this.remoteDataSource,
    @required this.networkInfo,
  });

  @override
  Future<Either<Failure, Memory>> saveMemory(
      Memory memory, List<MediaCollection> mediaCollectionList) async {
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
}
