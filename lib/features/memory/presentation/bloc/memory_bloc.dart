import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mood_manager/core/error/failures.dart';
import 'package:mood_manager/core/usecases/usecase.dart';
import 'package:mood_manager/features/common/domain/entities/media.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection_mapping.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:mood_manager/features/memory/domain/entities/memory_collection.dart';
import 'package:mood_manager/features/memory/domain/entities/memory_collection_mapping.dart';
import 'package:mood_manager/features/memory/domain/usecases/add_memory_to_collection.dart';
import 'package:mood_manager/features/memory/domain/usecases/archive_memory.dart';
import 'package:mood_manager/features/memory/domain/usecases/get_archive_memory_list.dart';
import 'package:mood_manager/features/memory/domain/usecases/get_media_collection_list.dart';
import 'package:mood_manager/features/memory/domain/usecases/get_memory_collection_list.dart';
import 'package:mood_manager/features/memory/domain/usecases/get_memory_list.dart';
import 'package:mood_manager/features/memory/domain/usecases/get_memory_list_by_collection.dart';
import 'package:mood_manager/features/memory/domain/usecases/get_memory_list_by_date.dart';
import 'package:mood_manager/features/memory/domain/usecases/get_memory_list_by_media.dart';
import 'package:mood_manager/features/metadata/domain/usecases/add_activity.dart';
import 'package:mood_manager/features/memory/domain/usecases/save_memory.dart';
import 'package:mood_manager/features/mood_manager/presentation/bloc/activity_list_bloc.dart';

part 'memory_event.dart';
part 'memory_state.dart';

class MemoryBloc extends Bloc<MemoryEvent, MemoryState> {
  final SaveMemory saveMemory;
  final ArchiveMemory archiveMemory;
  final GetMemoryList getMemoryList;
  final GetArchiveMemoryList getArchiveMemoryList;
  final GetMemoryListByDate getMemoryListByDate;
  final AddActivity addActivity;
  final GetMemoryCollectionList getMemoryCollectionList;
  final AddMemoryToCollection addMemoryToCollection;
  final GetMemoryListByCollection getMemoryListByCollection;
  final GetMediaCollectionList getMediaCollectionList;
  final GetMemoryListByMedia getMemoryListByMedia;
  MemoryBloc({
    this.getArchiveMemoryList,
    this.getMemoryListByDate,
    this.saveMemory,
    this.addActivity,
    this.getMemoryList,
    this.archiveMemory,
    this.getMemoryCollectionList,
    this.addMemoryToCollection,
    this.getMemoryListByCollection,
    this.getMediaCollectionList,
    this.getMemoryListByMedia,
  }) : super(MemoryInitial());

  @override
  Stream<MemoryState> mapEventToState(
    MemoryEvent event,
  ) async* {
    if (event is SaveMemoryEvent) {
      yield MemorySaving(memory: event.memory);
      final mayBeMemorySaved = await saveMemory(
          MultiParams([event.memory, event.mediaCollectionMappingList]));
      yield* _eitherSavedOrErrorState(mayBeMemorySaved, event);
    } else if (event is GetMemoryListEvent) {
      yield MemoryListLoading();
      final mayBeMemoryList = await getMemoryList(NoParams());
      yield* _eitherListLoadedOrErrorState(mayBeMemoryList, event);
    } else if (event is GetMemoryListByDateEvent) {
      yield MemoryListLoading();
      final mayBeMemoryList = await getMemoryListByDate(Params(event.date));
      yield* _eitherListLoadedOrErrorState(mayBeMemoryList, event);
    } else if (event is GetArchiveMemoryListEvent) {
      yield MemoryListLoading();
      final mayBeMemoryListMapByArchiveCollection =
          await getArchiveMemoryList(NoParams());
      yield* _eitherArchiveListLoadedOrErrorState(
          mayBeMemoryListMapByArchiveCollection, event);
    } else if (event is ArchiveMemoryEvent) {
      yield MemorySaving(memory: event.memory);
      final mayBeMemorySaved = await saveMemory(
          MultiParams([event.memory, event.mediaCollectionMappingList]));
      await archiveMemory(Params(event.memory));
      yield* _eitherSavedOrErrorState(mayBeMemorySaved, event);
    } else if (event is GetMemoryCollectionListEvent) {
      yield MemoryListLoading();
      final mayBeMemoryCollectionList =
          await getMemoryCollectionList(NoParams());
      yield* _eitherCollectionListLoadedOrErrorState(
          mayBeMemoryCollectionList, event);
    } else if (event is AddMemoryToCollectionEvent) {
      yield MemoryListLoading();
      final mayBeMemoryCollectionMapping =
          await addMemoryToCollection(Params(event.memoryCollectionMapping));
      yield* _eitherMemoryCollectionMappingSavedOrErrorState(
          mayBeMemoryCollectionMapping);
    } else if (event is GetMemoryListByCollectionEvent) {
      yield MemoryListLoading();
      final mayBeMemoryList =
          await getMemoryListByCollection(Params(event.memoryCollection));
      yield* _eitherListLoadedOrErrorState(mayBeMemoryList, event);
    } else if (event is GetMediaCollectionListEvent) {
      yield MemoryListLoading();
      final mayBeMediaCollectionList = await getMediaCollectionList(NoParams());
      yield* _eitherMediaCollectionListLoadedOrErrorState(
          mayBeMediaCollectionList, event);
    } else if (event is GetMemoryListByMediaEvent) {
      yield MemoryListLoading();
      final mayBeMemoryList = await getMemoryListByMedia(Params(event.media));
      yield* _eitherListLoadedOrErrorState(mayBeMemoryList, event);
    }
  }

  Stream<MemoryState> _eitherMemoryCollectionMappingSavedOrErrorState(
      Either<Failure, MemoryCollectionMapping> failureOrMood) async* {
    yield failureOrMood.fold(
      (failure) => MemorySaveError(message: _mapFailureToMessage(failure)),
      (memoryCollectionMapping) => AddedToMemoryCollection(
          memoryCollectionMapping: memoryCollectionMapping),
    );
  }

  Stream<MemoryState> _eitherSavedOrErrorState(
      Either<Failure, Memory> failureOrMood, MemoryEvent event) async* {
    yield failureOrMood.fold(
        (failure) => MemorySaveError(message: _mapFailureToMessage(failure)),
        (memory) => MemorySaved(memory: memory));
  }

  Stream<MemoryState> _eitherListLoadedOrErrorState(
      Either<Failure, List<Memory>> failureOrMood, MemoryEvent event) async* {
    yield failureOrMood.fold(
      (failure) => MemoryListError(message: _mapFailureToMessage(failure)),
      (memoryList) => MemoryListLoaded(memoryList: memoryList),
    );
  }

  Stream<MemoryState> _eitherArchiveListLoadedOrErrorState(
      Either<Failure, MapEntry<MemoryCollection, List<Memory>>> failureOrMood,
      MemoryEvent event) async* {
    yield failureOrMood.fold(
      (failure) => MemoryListError(message: _mapFailureToMessage(failure)),
      (memoryList) => MemoryListLoaded(
          memoryList: memoryList.value, memoryCollection: memoryList.key),
    );
  }

  Stream<MemoryState> _eitherCollectionListLoadedOrErrorState(
      Either<Failure, List<MemoryCollection>> failureOrMood,
      MemoryEvent event) async* {
    yield failureOrMood.fold(
      (failure) => MemoryListError(message: _mapFailureToMessage(failure)),
      (memoryCollectionList) => MemoryCollectionListLoaded(
          memoryCollectionList: memoryCollectionList),
    );
  }

  Stream<MemoryState> _eitherMediaCollectionListLoadedOrErrorState(
      Either<Failure, List<MediaCollection>> failureOrMood,
      MemoryEvent event) async* {
    yield failureOrMood.fold(
      (failure) => MemoryListError(message: _mapFailureToMessage(failure)),
      (mediaCollectionList) =>
          MediaCollectionListLoaded(mediaCollectionList: mediaCollectionList),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case CacheFailure:
        return CACHE_FAILURE_MESSAGE;
      default:
        return 'Unexpected error';
    }
  }
}
