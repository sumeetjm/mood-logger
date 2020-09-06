import 'package:equatable/equatable.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_mood.dart';

abstract class TMoodState extends Equatable {
  const TMoodState();
}

class TMoodInitial extends TMoodState {
  @override
  List<Object> get props => [];
}

class TMoodSaved extends TMoodState {
  final TMood tMood;
  final String action;

  TMoodSaved({this.tMood, this.action});

  @override
  List<Object> get props => [tMood];
}

class TMoodSaveError extends TMoodState {
  final String message;

  TMoodSaveError({this.message});

  @override
  List<Object> get props => [message];
}

class TMoodListLoaded extends TMoodState {
  final List<TMood> tMoodList;

  TMoodListLoaded({this.tMoodList});

  @override
  List<Object> get props => [tMoodList];
}

class TMoodListError extends TMoodState {
  final String message;

  TMoodListError({this.message});

  @override
  List<Object> get props => [message];
}

class TMoodListLoading extends TMoodState {
  @override
  List<Object> get props => [];
}
