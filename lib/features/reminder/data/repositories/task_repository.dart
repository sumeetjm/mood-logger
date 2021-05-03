import 'package:dartz/dartz.dart' show Either;
import 'package:mood_manager/core/error/failures.dart';
import 'package:mood_manager/features/reminder/domain/entities/task.dart';

abstract class TaskRepository {
  Future<Either<Failure, Task>> saveTask(Task task, {int cancelNotificationId});
  Future<Either<Failure, List<Task>>> getTaskList();
}
