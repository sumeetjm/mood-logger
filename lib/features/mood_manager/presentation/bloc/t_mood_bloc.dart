import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:mood_manager/core/error/failures.dart';
import 'package:mood_manager/core/usecases/usecase.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_mood.dart';
import 'package:mood_manager/features/mood_manager/domain/usecases/get_t_mood_list.dart';
import 'package:mood_manager/features/mood_manager/domain/usecases/save_t_mood.dart';
import 'package:mood_manager/features/mood_manager/presentation/bloc/activity_list_index.dart';
import 'package:mood_manager/features/mood_manager/presentation/bloc/t_mood_index.dart';
import 'package:meta/meta.dart';

class TMoodBloc extends Bloc<TMoodEvent, TMoodState> {
  final SaveTMood saveTMood;
  final GetTMoodList getTMoodList;

  TMoodBloc({
    @required SaveTMood saveTMood,
    @required GetTMoodList getTMoodList,
  })  : assert(saveTMood != null),
        assert(getTMoodList != null),
        this.saveTMood = saveTMood,
        this.getTMoodList = getTMoodList,
        super(TMoodInitial());

  @override
  Stream<TMoodState> mapEventToState(
    TMoodEvent event,
  ) async* {
    //debugger(when: true);
    if (event is SaveTMoodEvent) {
      final failureOrMood = await saveTMood(Params(event.tMood));
      yield* _eitherSavedOrErrorState(failureOrMood, event);
    } else if (event is GetTMoodListEvent) {
      yield TMoodListLoading();
      final failureOrMoodList = await getTMoodList(NoParams());
      yield* _eitherTMoodListLoadedOrErrorState(failureOrMoodList);
    }
  }

  Stream<TMoodState> _eitherTMoodListLoadedOrErrorState(
    Either<Failure, List<TMood>> failureOrMoodList,
  ) async* {
    yield failureOrMoodList.fold(
      (failure) => TMoodListError(message: _mapFailureToMessage(failure)),
      (tMoodList) => TMoodListLoaded(tMoodList: tMoodList),
    );
  }

  Stream<TMoodState> _eitherSavedOrErrorState(
      Either<Failure, TMood> failureOrMood, SaveTMoodEvent event) async* {
    yield failureOrMood.fold(
      (failure) => TMoodSaveError(message: _mapFailureToMessage(failure)),
      (mood) => TMoodSaved(tMood: mood, action: event.action),
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
