import 'package:equatable/equatable.dart';
import 'package:mood_manager/features/mood_manager/data/models/t_mood_model.dart';

abstract class TMoodEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SaveTMoodEvent extends TMoodEvent {
  final TMoodModel tMood;

  SaveTMoodEvent(this.tMood);

  @override
  List<Object> get props => [tMood];
}

class GetTMoodListEvent extends TMoodEvent {
  GetTMoodListEvent();

  @override
  List<Object> get props => [];
}
