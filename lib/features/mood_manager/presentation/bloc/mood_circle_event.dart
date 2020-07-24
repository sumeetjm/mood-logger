import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class MoodCircleEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetMoodMetaEvent extends MoodCircleEvent {}
