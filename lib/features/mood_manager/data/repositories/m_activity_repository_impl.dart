import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:mood_manager/features/mood_manager/data/datasources/m_activity_remote_data_source.dart';
import 'package:mood_manager/features/mood_manager/data/models/m_activity_model.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_activity.dart';
import 'package:mood_manager/features/mood_manager/domain/repositories/m_activity_repository.dart';

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
}
