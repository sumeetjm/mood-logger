import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:mood_manager/features/common/domain/entities/base_states.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity_type.dart';

@immutable
abstract class ActivityListState extends Equatable {
  @override
  List<Object> get props => [];
}

class ActivityListEmpty extends ActivityListState {}

class ActivityListLoading extends ActivityListState with Loading {}

class ActivityListLoaded extends ActivityListState with Completed {
  final List<MActivity> mActivityList;

  ActivityListLoaded({@required this.mActivityList});

  @override
  List<Object> get props => [mActivityList];
}

class ActivityTypeListLoaded extends ActivityListState with Completed {
  final List<MActivityType> mActivityTypeList;

  ActivityTypeListLoaded({@required this.mActivityTypeList});

  @override
  List<Object> get props => [mActivityTypeList];
}

class ActivityListError extends ActivityListState with Completed {
  final String message;

  ActivityListError({@required this.message});

  @override
  List<Object> get props => [message];
}
