import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:mood_manager/features/common/data/datasources/common_remote_data_source.dart';
import 'package:mood_manager/features/metadata/data/datasources/m_activity_remote_data_source.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity_type.dart';
import 'package:mood_manager/features/metadata/domain/repositories/m_activity_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';

class MActivityRepositoryImpl implements MActivityRepository {
  final MActivityRemoteDataSource remoteDataSource;
  final CommonRemoteDataSource commonRemoteDataSource;

  MActivityRepositoryImpl({
    @required this.remoteDataSource,
    @required this.commonRemoteDataSource,
  });

  @override
  Future<Either<Failure, List<MActivity>>> getMActivityList() async {
    try {
      await commonRemoteDataSource.checkConnectivity();
      final mActivityList = await remoteDataSource.getMActivityList();
      return Right(mActivityList);
    } on ServerException {
      return Left(ServerFailure());
    } on NoInternetException {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, List<MActivityType>>> getMActivityTypeList() async {
    try {
      await commonRemoteDataSource.checkConnectivity();
      final mActivityTypeList = await remoteDataSource.getMActivityTypeList();
      return Right(mActivityTypeList);
    } on ServerException {
      return Left(ServerFailure());
    } on NoInternetException {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, MActivity>> addMActivity(
      final MActivity toBeAddedMActivity) async {
    try {
      await commonRemoteDataSource.checkConnectivity();
      final mActivity = await remoteDataSource.addMActivity(toBeAddedMActivity);
      return Right(mActivity);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<MActivity>>> getMActivityListBySearchText(
      String searchText) async {
    try {
      await commonRemoteDataSource.checkConnectivity();
      final mActivityList =
          await remoteDataSource.getMActivityListBySearchText(searchText);
      return Right(mActivityList);
    } on ServerException {
      return Left(ServerFailure());
    } on NoInternetException {
      return Left(NoInternetFailure());
    }
  }
}
