part of 'memory_bloc.dart';

abstract class MemoryEvent extends Equatable {
  const MemoryEvent();

  @override
  List<Object> get props => [];
}

class SaveMemoryEvent extends MemoryEvent {
  final Memory memory;
  final List<MediaCollectionMapping> mediaCollectionMappingList;

  SaveMemoryEvent({this.memory, this.mediaCollectionMappingList = const []});

  @override
  List<Object> get props => [memory, ...super.props];
}

class GetMemoryListEvent extends MemoryEvent {}

class GetMemoryListByDateEvent extends MemoryEvent {
  final DateTime date;

  GetMemoryListByDateEvent(this.date);
}

class GetArchiveMemoryListEvent extends MemoryEvent {}

class ArchiveMemoryEvent extends MemoryEvent {
  final Memory memory;
  final List<MediaCollectionMapping> mediaCollectionMappingList;

  ArchiveMemoryEvent({this.memory, this.mediaCollectionMappingList = const []});

  @override
  List<Object> get props =>
      [memory, this.mediaCollectionMappingList, ...super.props];
}

class GetMemoryCollectionListEvent extends MemoryEvent {}

class AddMemoryToCollectionEvent extends MemoryEvent {
  final MemoryCollectionMapping memoryCollectionMapping;

  AddMemoryToCollectionEvent(this.memoryCollectionMapping);

  @override
  List<Object> get props => [this.memoryCollectionMapping, ...super.props];
}

class GetMemoryListByCollectionEvent extends MemoryEvent {
  final MemoryCollection memoryCollection;

  GetMemoryListByCollectionEvent(this.memoryCollection);

  @override
  List<Object> get props => [this.memoryCollection, ...super.props];
}

class GetMediaCollectionListEvent extends MemoryEvent {}
