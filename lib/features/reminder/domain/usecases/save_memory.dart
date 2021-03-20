import 'package:mood_manager/features/memory/data/repositories/memory_repository.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:dartz/dartz.dart' show Either;
import 'package:mood_manager/features/reminder/data/repositories/task_repository.dart';
import 'package:mood_manager/features/reminder/domain/entities/task.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class SaveTask implements UseCase<Task, Params<Task>> {
  final TaskRepository repository;

  SaveTask(this.repository);

  @override
  Future<Either<Failure, Task>> call(Params<Task> params) async {
    return await repository.saveTask(params.param);
  }
}
