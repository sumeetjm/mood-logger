import 'package:equatable/equatable.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_mood.dart';

abstract class TMoodEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SaveTMoodEvent extends TMoodEvent {
  final TMood tMood;
  final String action;

  SaveTMoodEvent(this.tMood, this.action);

  @override
  List<Object> get props => [tMood, action, ...super.props];
}

class GetTMoodListEvent extends TMoodEvent {
  GetTMoodListEvent();
}
