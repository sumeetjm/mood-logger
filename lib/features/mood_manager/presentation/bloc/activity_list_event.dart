import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ActivityListEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetActivityMetaEvent extends ActivityListEvent {}

