import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mood_manager/core/error/failures.dart';
import 'package:mood_manager/core/usecases/usecase.dart';
import 'package:mood_manager/features/common/domain/entities/base_states.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity_type.dart';
import 'package:mood_manager/features/metadata/domain/usecases/add_activity.dart';
import 'package:mood_manager/features/metadata/domain/usecases/get_activity_list.dart';
import 'package:mood_manager/features/metadata/domain/usecases/get_activity_type_list.dart';
import 'package:mood_manager/features/metadata/domain/usecases/search_activity_list.dart';
import 'package:mood_manager/features/mood_manager/presentation/bloc/activity_list_bloc.dart';

part 'activity_event.dart';
part 'activity_state.dart';

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  final GetActivityList getActivityList;
  final GetActivityTypeList getActivityTypeList;
  final AddActivity addActivity;
  final SearchActivityList searchActivityList;
  ActivityBloc({
    this.getActivityList,
    this.getActivityTypeList,
    this.addActivity,
    this.searchActivityList,
  }) : super(ActivityInitial());

  @override
  Stream<ActivityState> mapEventToState(
    ActivityEvent event,
  ) async* {
    if (event is GetActivityListEvent) {
      yield ActivityLoading();
      final mayBeActivityList = await getActivityList(NoParams());
      yield* _eitherActivityListLoadedOrErrorState(mayBeActivityList);
    } else if (event is GetActivityTypeListEvent) {
      yield ActivityLoading();
      final mayBeActivityTypeList = await getActivityTypeList(NoParams());
      yield* _eitherActivityTypeListLoadedOrErrorState(mayBeActivityTypeList);
    } else if (event is AddActivityEvent) {
      yield ActivityLoading();
      final mayBeActivity = await addActivity(Params(event.activity));
      yield* _eitherActivityLoadedOrErrorState(mayBeActivity);
    } else if (event is SearchActivityListEvent) {
      yield ActivityLoading();
      final mayBeActivityList =
          await searchActivityList(Params(event.searchText));
      yield* _eitherActivityListLoadedOrErrorState(mayBeActivityList);
    }
  }

  Stream<ActivityState> _eitherActivityListLoadedOrErrorState(
    Either<Failure, List<MActivity>> mayBeActivityList,
  ) async* {
    yield mayBeActivityList.fold(
      (failure) => ActivityError(message: _mapFailureToMessage(failure)),
      (activityList) => ActivityListLoaded(activityList: activityList),
    );
  }

  Stream<ActivityState> _eitherActivityTypeListLoadedOrErrorState(
    Either<Failure, List<MActivityType>> mayBeActivityTypeList,
  ) async* {
    yield mayBeActivityTypeList.fold(
      (failure) => ActivityError(message: _mapFailureToMessage(failure)),
      (activityTypeList) =>
          ActivityTypeListLoaded(activityTypeList: activityTypeList),
    );
  }

  Stream<ActivityState> _eitherActivityLoadedOrErrorState(
    Either<Failure, MActivity> mayBeActivity,
  ) async* {
    yield mayBeActivity.fold(
      (failure) => ActivityError(message: _mapFailureToMessage(failure)),
      (activity) => ActivityAdded(activity: activity),
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
