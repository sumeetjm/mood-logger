part of 'task_bloc.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object> get props => [];
}

class SaveTaskEvent extends TaskEvent {
  final Task task;

  SaveTaskEvent({this.task});

  @override
  List<Object> get props => [task, ...super.props];
}

class GetTaskListEvent extends TaskEvent {
  GetTaskListEvent();
}
