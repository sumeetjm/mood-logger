import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mood_manager/core/error/failures.dart';
import 'package:mood_manager/core/usecases/usecase.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:mood_manager/features/memory/domain/usecases/get_memory_list.dart';
import 'package:mood_manager/features/memory/domain/usecases/get_memory_list_by_date.dart';
import 'package:mood_manager/features/metadata/domain/usecases/add_activity.dart';
import 'package:mood_manager/features/memory/domain/usecases/save_memory.dart';
import 'package:mood_manager/features/mood_manager/presentation/bloc/activity_list_bloc.dart';

part 'memory_event.dart';
part 'memory_state.dart';

class MemoryBloc extends Bloc<MemoryEvent, MemoryState> {
  final SaveMemory saveMemory;
  final GetMemoryList getMemoryList;
  final GetMemoryListByDate getMemoryListByDate;
  final AddActivity addActivity;
  MemoryBloc(
      {this.getMemoryListByDate,
      this.saveMemory,
      this.addActivity,
      this.getMemoryList})
      : super(MemoryInitial());

  @override
  Stream<MemoryState> mapEventToState(
    MemoryEvent event,
  ) async* {
    if (event is SaveMemoryEvent) {
      yield MemorySaving(memory: event.memory);
      final mayBeMemorySaved = await saveMemory(
          MultiParams([event.memory, event.mediaCollectionList]));
      yield* _eitherSavedOrErrorState(mayBeMemorySaved);
    } else if (event is GetMemoryListEvent) {
      yield MemoryListLoading();
      final mayBeMemoryList = await getMemoryList(NoParams());
      yield* _eitherListLoadedOrErrorState(mayBeMemoryList);
    } else if (event is GetMemoryListByDateEvent) {
      yield MemoryListLoading();
      final mayBeMemoryList = await getMemoryListByDate(Params(event.date));
      yield* _eitherListLoadedOrErrorState(mayBeMemoryList);
    }
  }

  Stream<MemoryState> _eitherSavedOrErrorState(
      Either<Failure, Memory> failureOrMood) async* {
    yield failureOrMood.fold(
      (failure) => MemorySaveError(message: _mapFailureToMessage(failure)),
      (memory) => MemorySaved(memory: memory),
    );
  }

  Stream<MemoryState> _eitherListLoadedOrErrorState(
      Either<Failure, List<Memory>> failureOrMood) async* {
    yield failureOrMood.fold(
      (failure) => MemoryListError(message: _mapFailureToMessage(failure)),
      (memoryList) => MemoryListLoaded(memoryList: memoryList),
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
