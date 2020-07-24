import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mood_manager/core/error/failures.dart';
import 'package:mood_manager/core/usecases/usecase.dart';
import 'package:mood_manager/features/mood_manager/data/models/m_activity_model.dart';
import 'package:mood_manager/features/mood_manager/domain/usecases/get_m_activity_list.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

import './activity_list_index.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';

class ActivityListBloc extends Bloc<ActivityListEvent, ActivityListState> {
  final GetMActivityList getActivityMetaList;

  ActivityListBloc({@required GetMActivityList getActivityMetaList})
      : assert(getActivityMetaList != null),
        this.getActivityMetaList = getActivityMetaList,
        super(ActivityListEmpty());

  @override
  Stream<ActivityListState> mapEventToState(
    ActivityListEvent event,
  ) async* {
    if (event is GetActivityMetaEvent) {
      yield ActivityListLoading();
      final failureOrActivityList = await getActivityMetaList(NoParams());
      yield* _eitherLoadedOrErrorState(failureOrActivityList);
    }
  }

  Stream<ActivityListState> _eitherLoadedOrErrorState(
    Either<Failure, Map<String, List<MActivityModel>>> failureOrActivityList,
  ) async* {
    yield failureOrActivityList.fold(
      (failure) => ActivityListError(message: _mapFailureToMessage(failure)),
      (activityList) =>
          ActivityListLoaded(mActivityListGroupByType: activityList),
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
