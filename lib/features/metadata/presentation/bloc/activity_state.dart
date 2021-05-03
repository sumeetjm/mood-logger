part of 'activity_bloc.dart';

abstract class ActivityState extends Equatable {
  const ActivityState();

  @override
  List<Object> get props => [];
}

class ActivityInitial extends ActivityState {}

class ActivityListLoading extends ActivityState with Loading {}

class ActivityAdding extends ActivityState with Loading {}

class ActivityTypeListLoading extends ActivityState with Loading {}

class ActivityLoading extends ActivityState with Loading {}

class ActivityError extends ActivityState with Completed {
  final String message;

  ActivityError({this.message});

  @override
  List<Object> get props => [this.message];
}

class ActivityListLoaded extends ActivityState with Completed {
  final List<MActivity> activityList;

  ActivityListLoaded({this.activityList});

  @override
  List<Object> get props => [this.activityList];
}

class ActivityAdded extends ActivityState with Completed {
  final MActivity activity;

  ActivityAdded({this.activity});

  @override
  List<Object> get props => [this.activity];
}

class ActivityTypeListLoaded extends ActivityState with Completed {
  final List<MActivityType> activityTypeList;

  ActivityTypeListLoaded({this.activityTypeList});

  @override
  List<Object> get props => [this.activityTypeList];
}
