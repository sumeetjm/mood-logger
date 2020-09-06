import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_activity.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_activity_type.dart';

@immutable
abstract class ActivityListState extends Equatable {
  @override
  List<Object> get props => [];
}

class ActivityListEmpty extends ActivityListState {}

class ActivityListLoading extends ActivityListState {}

class ActivityListLoaded extends ActivityListState {
  final List<MActivity> mActivityList;

  ActivityListLoaded({@required this.mActivityList});

  @override
  List<Object> get props => [mActivityList];
}

class ActivityTypeListLoaded extends ActivityListState {
  final List<MActivityType> mActivityTypeList;

  ActivityTypeListLoaded({@required this.mActivityTypeList});

  @override
  List<Object> get props => [mActivityTypeList];
}

class ActivityListError extends ActivityListState {
  final String message;

  ActivityListError({@required this.message});

  @override
  List<Object> get props => [message];
}
