import 'package:mood_manager/features/mood_manager/domain/entities/m_mood.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class MoodCircleState extends Equatable {
  @override
  List<Object> get props => [];
}

class MoodCircleEmpty extends MoodCircleState {}

class MoodCircleLoading extends MoodCircleState {}

class MoodCircleLoaded extends MoodCircleState {
  final List<MMood> moodList;

  MoodCircleLoaded({@required this.moodList});

  @override
  List<Object> get props => [moodList];
}

class MoodCircleError extends MoodCircleState {
  final String message;

  MoodCircleError({@required this.message});

  @override
  List<Object> get props => [message];
}
