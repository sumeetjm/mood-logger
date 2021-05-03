import 'package:mood_manager/features/metadata/data/datasources/m_mood_remote_data_source.dart';
import 'package:mood_manager/features/metadata/domain/repositories/m_mood_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/m_mood.dart';

class MMoodRepositoryImpl implements MMoodRepository {
  final MMoodRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  MMoodRepositoryImpl({
    @required this.remoteDataSource,
    @required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<MMood>>> getMMoodList() async {
    if (await networkInfo.isConnected) {
      try {
          final remoteTrivia = await remoteDataSource.getMMoodList();
          return Right(remoteTrivia);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(ServerFailure());
    }
  }
}
