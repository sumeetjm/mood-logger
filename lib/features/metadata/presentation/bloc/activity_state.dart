part of 'activity_bloc.dart';

abstract class ActivityState extends Equatable {
  const ActivityState();

  @override
  List<Object> get props => [];
}

class ActivityInitial extends ActivityState {}

class ActivityListLoading extends ActivityState {}

class ActivityAdding extends ActivityState {}

class ActivityTypeListLoading extends ActivityState {}

class ActivityLoading extends ActivityState {}

class ActivityError extends ActivityState {
  final String message;

  ActivityError({this.message});

  @override
  List<Object> get props => [this.message];
}

class ActivityListLoaded extends ActivityState {
  final List<MActivity> activityList;

  ActivityListLoaded({this.activityList});

  @override
  List<Object> get props => [this.activityList];
}

class ActivityAdded extends ActivityState {
  final MActivity activity;

  ActivityAdded({this.activity});

  @override
  List<Object> get props => [this.activity];
}

class ActivityTypeListLoaded extends ActivityState {
  final List<MActivityType> activityTypeList;

  ActivityTypeListLoaded({this.activityTypeList});

  @override
  List<Object> get props => [this.activityTypeList];
}
