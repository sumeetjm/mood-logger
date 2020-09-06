import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:mood_manager/core/error/failures.dart';
import 'package:mood_manager/core/usecases/usecase.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_activity_type.dart';
import 'package:mood_manager/features/mood_manager/domain/usecases/get_m_activity_list.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

import './activity_list_index.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';

class ActivityListBloc extends Bloc<ActivityListEvent, ActivityListState> {
  final GetMActivityTypeList getMActivityTypeList;

  ActivityListBloc({@required GetMActivityTypeList getMActivityTypeList})
      : assert(getMActivityTypeList != null),
        this.getMActivityTypeList = getMActivityTypeList,
        super(ActivityListEmpty());

  @override
  Stream<ActivityListState> mapEventToState(
    ActivityListEvent event,
  ) async* {
    //debugger(when:false);
    if (event is GetMActivityListEvent) {
      /*yield ActivityListLoading();
      final failureOrActivityList = await getActivityMetaList(NoParams());
      yield* _eitherLoadedOrErrorState(failureOrActivityList);*/
    } else if (event is GetMActivityTypeListEvent) {
      yield ActivityListLoading();
      final failureOrActivityTypeList = await getMActivityTypeList(NoParams());
      yield* _eitherLoadedOrErrorState(failureOrActivityTypeList);
    }
  }

  Stream<ActivityListState> _eitherLoadedOrErrorState(
    Either<Failure, List<MActivityType>> failureOrActivityTypeList,
  ) async* {
    yield failureOrActivityTypeList.fold(
      (failure) => ActivityListError(message: _mapFailureToMessage(failure)),
      (activityTypeList) =>
          ActivityTypeListLoaded(mActivityTypeList: activityTypeList),
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
