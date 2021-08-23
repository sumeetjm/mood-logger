part of 'task_bloc.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object> get props => [];
}

class SaveTaskEvent extends TaskEvent {
  final Task task;
  final int cancelNotificationId;
  SaveTaskEvent({this.task, this.cancelNotificationId});

  @override
  List<Object> get props => [task, cancelNotificationId, ...super.props];
}

class GetTaskListEvent extends TaskEvent {
  GetTaskListEvent();
}
