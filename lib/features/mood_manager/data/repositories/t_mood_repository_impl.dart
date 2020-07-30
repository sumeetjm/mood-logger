import 'dart:developer';

import 'package:mood_manager/features/mood_manager/data/datasources/t_mood_remote_data_source.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_activity.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_mood.dart';
import 'package:mood_manager/features/mood_manager/domain/repositories/t_mood_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';

class TMoodRepositoryImpl implements TMoodRepository {
  final TMoodRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  TMoodRepositoryImpl({
    @required this.remoteDataSource,
    @required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<TMood>>> getTMoodList() async {
    if (await networkInfo.isConnected) {
      try {
        final tMoodList = await remoteDataSource.getTMoodList();
        return Right(tMoodList);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, TMood>> saveTMood(
      TMood tMood, List<TActivity> tActivityList) async {
    if (await networkInfo.isConnected) {
      //debugger(when: false);
      try {
        if (tMood.id != null) {
          final tMoodSaved = await remoteDataSource.updateTMood(
              tMood: tMood, tActivityList: tActivityList);
          return Right(tMoodSaved);
        } else {
          final tMoodSaved = await remoteDataSource.saveTMood(
              tMood: tMood, tActivityList: tActivityList);
          return Right(tMoodSaved);
        }
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(ServerFailure());
    }
  }
}
