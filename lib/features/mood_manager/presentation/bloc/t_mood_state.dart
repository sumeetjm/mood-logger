import 'package:equatable/equatable.dart';
import 'package:mood_manager/features/mood_manager/data/models/t_mood_model.dart';

abstract class TMoodState extends Equatable {
  const TMoodState();
}

class TMoodInitial extends TMoodState {
  @override
  List<Object> get props => [];
}

class TMoodSaved extends TMoodState {
  final TMoodModel tMood;

  TMoodSaved({this.tMood});

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
  final List<TMoodModel> tMoodList;

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
