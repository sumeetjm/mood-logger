part of 'task_bloc.dart';

abstract class TaskState extends Equatable {
  @override
  List<Object> get props => [];
}

class TaskInitial extends TaskState {
  @override
  List<Object> get props => [];
}

class TaskLoading extends TaskState with Loading {
  @override
  List<Object> get props => [];
}

class TaskSaved extends TaskState with Completed {
  final Task task;

  TaskSaved({this.task});

  @override
  List<Object> get props => [task, ...super.props];
}

class TaskListLoaded extends TaskState with Completed {
  final List<Task> taskList;

  TaskListLoaded({this.taskList});

  @override
  List<Object> get props => [taskList, ...super.props];
}

class TaskError extends TaskState with Completed {
  final String message;

  TaskError({this.message});

  @override
  List<Object> get props => [message, ...super.props];
}
