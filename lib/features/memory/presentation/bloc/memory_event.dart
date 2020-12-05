part of 'memory_bloc.dart';

abstract class MemoryEvent extends Equatable {
  const MemoryEvent();

  @override
  List<Object> get props => [];
}

class SaveMemoryEvent extends MemoryEvent {
  final Memory memory;
  final List<MediaCollection> mediaCollectionList;

  SaveMemoryEvent({this.memory, this.mediaCollectionList});

  @override
  List<Object> get props => [memory];
}

class GetMemoryListEvent extends MemoryEvent {}
