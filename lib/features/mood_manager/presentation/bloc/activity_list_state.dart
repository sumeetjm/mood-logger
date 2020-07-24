import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:mood_manager/features/mood_manager/data/models/m_activity_model.dart';

@immutable
abstract class ActivityListState extends Equatable {
  @override
  List<Object> get props => [];
}

class ActivityListEmpty extends ActivityListState {}

class ActivityListLoading extends ActivityListState {}

class ActivityListLoaded extends ActivityListState {
  final Map<String, List<MActivityModel>> mActivityListGroupByType;

  ActivityListLoaded({@required this.mActivityListGroupByType});

  @override
  List<Object> get props => [mActivityListGroupByType];
}

class ActivityListError extends ActivityListState {
  final String message;

  ActivityListError({@required this.message});

  @override
  List<Object> get props => [message];
}
