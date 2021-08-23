import 'package:mood_manager/core/error/exceptions.dart';
import 'package:mood_manager/core/error/failures.dart';
import 'package:dartz/dartz.dart' show Either, Right, Left;
import 'package:mood_manager/features/common/data/datasources/common_remote_data_source.dart';
import 'package:mood_manager/features/reminder/data/datasources/task_remote_data_source.dart';
import 'package:mood_manager/features/reminder/data/repositories/task_repository.dart';
import 'package:mood_manager/features/reminder/domain/entities/task.dart';

class TaskRepositoryImpl extends TaskRepository {
  final TaskRemoteDataSource remoteDataSource;
  final CommonRemoteDataSource commonRemoteDataSource;
  TaskRepositoryImpl({
    this.remoteDataSource,
    this.commonRemoteDataSource,
  });

  Future<Either<Failure, List<Task>>> getTaskList() async {
    try {
      await commonRemoteDataSource.checkConnectivity();
      final list = await remoteDataSource.getTaskList();
      return Right(list);
    } on ServerException {
      return Left(ServerFailure());
    } on NoInternetException {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, Task>> saveTask(Task task,
      {int cancelNotificationId}) async {
    try {
      await commonRemoteDataSource.checkConnectivity();
      final saved = await remoteDataSource.saveTask(task);
      return Right(saved);
    } on ServerException {
      return Left(ServerFailure());
    } on NoInternetException {
      return Left(NoInternetFailure());
    }
  }
}
