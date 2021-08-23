part of 'memory_bloc.dart';

abstract class MemoryEvent extends Equatable {
  const MemoryEvent();

  @override
  List<Object> get props => [];
}

class SaveMemoryEvent extends MemoryEvent {
  final Memory memory;
  final List<MediaCollectionMapping> mediaCollectionMappingList;
  final Task task;

  SaveMemoryEvent(
      {this.memory, this.mediaCollectionMappingList = const [], this.task});

  @override
  List<Object> get props => [memory, ...super.props];
}

class GetMemoryListEvent extends MemoryEvent {
  final String scrollToItemId;

  GetMemoryListEvent({this.scrollToItemId});
}

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

class GetMediaCollectionListEvent extends MemoryEvent {
  final bool skipEmpty;
  final String mediaType;
  GetMediaCollectionListEvent({this.skipEmpty = false, this.mediaType});
  @override
  List<Object> get props => [this.skipEmpty, ...super.props];
}

class GetMemoryListByMediaEvent extends MemoryEvent {
  final Media media;

  GetMemoryListByMediaEvent(this.media);

  @override
  List<Object> get props => [this.media, ...super.props];
}

class GetSingleMemoryByIdEvent extends MemoryEvent {
  final String memoryId;

  GetSingleMemoryByIdEvent(this.memoryId);

  @override
  List<Object> get props => [this.memoryId, ...super.props];
}

class SaveMemoryCollectionEvent extends MemoryEvent {
  final MemoryCollection memoryCollection;
  SaveMemoryCollectionEvent(this.memoryCollection);
  @override
  List<Object> get props => [this.memoryCollection, ...super.props];
}
