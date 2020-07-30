import 'package:equatable/equatable.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_activity.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_mood.dart';

abstract class TMoodEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SaveTMoodEvent extends TMoodEvent {
  final TMood tMood;
  final List<TActivity> tActivityList;

  SaveTMoodEvent(this.tMood, this.tActivityList);

  @override
  List<Object> get props => [tMood, tActivityList, ...super.props];
}

class GetTMoodListEvent extends TMoodEvent {
  GetTMoodListEvent();
}
