import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart' show Either;
import 'package:equatable/equatable.dart';
import 'package:mood_manager/core/error/failures.dart';
import 'package:mood_manager/core/usecases/usecase.dart';
import 'package:mood_manager/features/common/domain/entities/base_states.dart';
import 'package:mood_manager/features/mood_manager/presentation/bloc/activity_list_bloc.dart';
import 'package:mood_manager/features/reminder/domain/entities/task.dart';
import 'package:mood_manager/features/reminder/domain/usecases/get_memory_list.dart';
import 'package:mood_manager/features/reminder/domain/usecases/save_memory.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final SaveTask saveTask;
  final GetTaskList getTaskList;

  TaskBloc({
    this.saveTask,
    this.getTaskList,
  }) : super(TaskInitial());

  @override
  Stream<TaskState> mapEventToState(
    TaskEvent event,
  ) async* {
    if (event is GetTaskListEvent) {
      yield TaskLoading();
      final either = await getTaskList(NoParams());
      yield* _eitherTaskListOrErrorState(either);
    } else if (event is SaveTaskEvent) {
      yield TaskLoading();
      final either =
          await saveTask(MultiParams([event.task, event.cancelNotificationId]));
      yield* _eitherTaskOrErrorState(either);
    }
  }

  Stream<TaskState> _eitherTaskListOrErrorState(
      Either<Failure, List<Task>> failureOrMood) async* {
    yield failureOrMood.fold(
      (failure) => TaskError(message: _mapFailureToMessage(failure)),
      (taskList) => TaskListLoaded(taskList: taskList),
    );
  }

  Stream<TaskState> _eitherTaskOrErrorState(
      Either<Failure, Task> failureOrMood) async* {
    yield failureOrMood.fold(
      (failure) => TaskError(message: _mapFailureToMessage(failure)),
      (task) => TaskSaved(task: task),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case CacheFailure:
        return CACHE_FAILURE_MESSAGE;
      default:
        return 'Unexpected error';
    }
  }
}
