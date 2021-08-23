part of 'memory_bloc.dart';

abstract class MemoryState extends Equatable {
  @override
  List<Object> get props => [];
}

abstract class MemoryProcessing extends MemoryState {}

abstract class MemoryCompleted extends MemoryState {}

class MemoryInitial extends MemoryState {}

class MemorySaved extends MemoryCompleted with Completed {
  final Memory memory;

  MemorySaved({this.memory});

  @override
  List<Object> get props => [memory, ...super.props];
}

class MemorySaving extends MemoryProcessing with Loading {
  final Memory memory;

  MemorySaving({this.memory});

  @override
  List<Object> get props => [memory, ...super.props];
}

class MemorySaveError extends MemoryCompleted with Completed {
  final String message;

  MemorySaveError({this.message});

  @override
  List<Object> get props => [message, ...super.props];
}

class MemoryListError extends MemoryCompleted with Completed {
  final String message;

  MemoryListError({this.message, String srcKey});

  @override
  List<Object> get props => [message, ...super.props];
}

class MemoryListLoading extends MemoryProcessing with Loading {}

// ignore: must_be_immutable
class MemoryListLoaded extends MemoryCompleted with Completed {
  final List<Memory> memoryList;
  MemoryCollection memoryCollection;
  final String scrollToItemId;

  MemoryListLoaded(
      {this.memoryList, this.memoryCollection, this.scrollToItemId});

  @override
  List<Object> get props =>
      [memoryList, memoryCollection, scrollToItemId, ...super.props];
}

class MemoryCollectionListLoaded extends MemoryCompleted with Completed {
  final List<MemoryCollection> memoryCollectionList;

  MemoryCollectionListLoaded({this.memoryCollectionList});

  @override
  List<Object> get props => [memoryCollectionList];
}

class AddedToMemoryCollection extends MemoryCompleted with Completed {
  final MemoryCollectionMapping memoryCollectionMapping;

  AddedToMemoryCollection({this.memoryCollectionMapping});

  @override
  List<Object> get props => [memoryCollectionMapping, ...super.props];
}

class MediaCollectionListLoaded extends MemoryCompleted with Completed {
  final List<MediaCollection> mediaCollectionList;

  MediaCollectionListLoaded({this.mediaCollectionList});

  @override
  List<Object> get props => [mediaCollectionList, ...super.props];
}

class SavedMemoryCollection extends MemoryCompleted with Completed {
  final MemoryCollection memoryCollection;
  SavedMemoryCollection(this.memoryCollection);
  @override
  List<Object> get props => [this.memoryCollection, ...super.props];
}

// ignore: must_be_immutable
class MemoryStoreState extends MemoryState {
  bool isSaving;
  bool isListLoading;
  bool isError;
  String message;
  List<Memory> memoryList;
  MemoryCollection memoryCollection;
  List<MemoryCollection> memoryCollectionList;
  List<MediaCollection> mediaCollectionList;
  MemoryCollectionMapping memoryCollectionMappingAdded;

  MemoryStoreState({
    this.isSaving,
    this.isListLoading,
    this.isError,
    this.message,
    this.memoryList,
    this.memoryCollection,
    this.memoryCollectionList,
    this.mediaCollectionList,
    this.memoryCollectionMappingAdded,
  });

  @override
  List<Object> get props => [
        isSaving,
        isListLoading,
        isError,
        message,
        memoryList,
        memoryCollection,
        memoryCollectionList,
        mediaCollectionList,
        memoryCollectionMappingAdded
      ];
}
