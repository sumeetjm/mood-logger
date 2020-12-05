import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:mood_manager/features/metadata/data/datasources/m_activity_remote_data_source.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity_type.dart';
import 'package:mood_manager/features/metadata/domain/repositories/m_activity_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';

class MActivityRepositoryImpl implements MActivityRepository {
  final MActivityRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  MActivityRepositoryImpl({
    @required this.remoteDataSource,
    @required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<MActivity>>> getMActivityList() async {
    if (await networkInfo.isConnected) {
      try {
        final mActivityList = await remoteDataSource.getMActivityList();
        return Right(mActivityList);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<MActivityType>>> getMActivityTypeList() async {
    if (await networkInfo.isConnected) {
      try {
        final mActivityTypeList = await remoteDataSource.getMActivityTypeList();
        return Right(mActivityTypeList);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, MActivity>> addMActivity(
      final MActivity toBeAddedMActivity) async {
    if (await networkInfo.isConnected) {
      try {
        final mActivity =
            await remoteDataSource.addMActivity(toBeAddedMActivity);
        return Right(mActivity);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<MActivity>>> getMActivityListBySearchText(
      String searchText) async {
    if (await networkInfo.isConnected) {
      try {
        final mActivityList =
            await remoteDataSource.getMActivityListBySearchText(searchText);
        return Right(mActivityList);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(ServerFailure());
    }
  }
}
