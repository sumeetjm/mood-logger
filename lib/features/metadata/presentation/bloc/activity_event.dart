part of 'activity_bloc.dart';

abstract class ActivityEvent extends Equatable {
  const ActivityEvent();

  @override
  List<Object> get props => [];
}

class GetActivityListEvent extends ActivityEvent {}

class SearchActivityListEvent extends ActivityEvent {
  final String searchText;

  SearchActivityListEvent({this.searchText});
}

class GetActivityTypeListEvent extends ActivityEvent {}

class AddActivityEvent extends ActivityEvent {
  final MActivity activity;

  AddActivityEvent({this.activity});
}
