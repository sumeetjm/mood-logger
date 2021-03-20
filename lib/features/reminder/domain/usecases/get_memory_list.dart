import 'package:dartz/dartz.dart' show Either;
import 'package:mood_manager/features/reminder/data/repositories/task_repository.dart';
import 'package:mood_manager/features/reminder/domain/entities/task.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class GetTaskList implements UseCase<List<Task>, NoParams> {
  final TaskRepository repository;

  GetTaskList(this.repository);

  @override
  Future<Either<Failure, List<Task>>> call(NoParams params) async {
    return await repository.getTaskList();
  }
}
