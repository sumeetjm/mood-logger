import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mood_manager/core/error/failures.dart';
import 'package:mood_manager/core/usecases/usecase.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_mood.dart';
import 'package:mood_manager/features/mood_manager/domain/usecases/get_m_mood_list.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

import './mood_circle_index.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';

class MoodCircleBloc extends Bloc<MoodCircleEvent, MoodCircleState> {
  final GetMMoodList getMoodMetaList;

  MoodCircleBloc({
    @required GetMMoodList getMoodMetaList,
  })  : assert(getMoodMetaList != null),
        this.getMoodMetaList = getMoodMetaList,
        super(MoodCircleEmpty());

  @override
  Stream<MoodCircleState> mapEventToState(
    MoodCircleEvent event,
  ) async* {
    if (event is GetMMoodListEvent) {
      yield MoodCircleLoading();
      final failureOrMoodList = await getMoodMetaList(NoParams());
      yield* _eitherLoadedOrErrorState(failureOrMoodList);
    }
  }

  Stream<MoodCircleState> _eitherLoadedOrErrorState(
    Either<Failure, List<MMood>> failureOrMoodList,
  ) async* {
    yield failureOrMoodList.fold(
      (failure) => MoodCircleError(message: _mapFailureToMessage(failure)),
      (moodList) => MoodCircleLoaded(moodList: moodList),
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
