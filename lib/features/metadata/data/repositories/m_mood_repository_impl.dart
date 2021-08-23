import 'package:mood_manager/features/common/data/datasources/common_remote_data_source.dart';
import 'package:mood_manager/features/metadata/data/datasources/m_mood_remote_data_source.dart';
import 'package:mood_manager/features/metadata/domain/repositories/m_mood_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/m_mood.dart';

class MMoodRepositoryImpl implements MMoodRepository {
  final MMoodRemoteDataSource remoteDataSource;
  final CommonRemoteDataSource commomRemoteDataSource;

  MMoodRepositoryImpl({
    @required this.remoteDataSource,
    @required this.commomRemoteDataSource,
  });

  @override
  Future<Either<Failure, List<MMood>>> getMMoodList() async {
    try {
      await commomRemoteDataSource.checkConnectivity();
      final remoteTrivia = await remoteDataSource.getMMoodList();
      return Right(remoteTrivia);
    } on ServerException {
      return Left(ServerFailure());
    } on NoInternetException {
      return Left(NoInternetFailure());
    }
  }
}
