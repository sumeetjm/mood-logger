import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mood_manager/core/error/failures.dart';
import 'package:mood_manager/core/usecases/usecase.dart';
import 'package:mood_manager/features/auth/domain/entitles/user.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/user_profile.dart';
import 'package:mood_manager/features/mood_manager/domain/usecases/get_current_user_profile.dart';
import 'package:mood_manager/features/mood_manager/domain/usecases/get_user_profile.dart';
import 'package:mood_manager/features/mood_manager/domain/usecases/save_user_profile.dart';
import 'package:mood_manager/features/mood_manager/presentation/bloc/activity_list_bloc.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetCurrentUserProfile getCurrentUserProfile;
  final GetUserProfile getUserProfile;
  final SaveUserProfile saveUserProfile;

  ProfileBloc({
    this.getCurrentUserProfile,
    this.getUserProfile,
    this.saveUserProfile,
  }) : super(ProfileInitial());

  @override
  Stream<ProfileState> mapEventToState(
    ProfileEvent event,
  ) async* {
    if (event is GetCurrentUserProfileEvent) {
      final either = await getCurrentUserProfile(NoParams());
      yield* _eitherUserProfileLoadedOrErrorState(either);
    } else if (event is GetUserProfileEvent) {
      yield UserProfileLoading();
      final either = await getUserProfile(Params(event.user));
      yield* _eitherUserProfileLoadedOrErrorState(either);
    } else if (event is SaveUserProfileEvent) {
      yield UserProfileSaving(userProfile: event.userProfile);
      final either = await saveUserProfile(Params(event.userProfile));
      yield* _eitherUserProfileSavedOrErrorState(either);
    }
  }

  Stream<ProfileState> _eitherUserProfileLoadedOrErrorState(
    Either<Failure, UserProfile> failureOrMoodList,
  ) async* {
    yield failureOrMoodList.fold(
      (failure) => UserProfileError(message: _mapFailureToMessage(failure)),
      (userProfile) => UserProfileLoaded(userProfile: userProfile),
    );
  }

  Stream<ProfileState> _eitherUserProfileSavedOrErrorState(
    Either<Failure, UserProfile> failureOrMoodList,
  ) async* {
    yield failureOrMoodList.fold(
      (failure) => UserProfileError(message: _mapFailureToMessage(failure)),
      (userProfile) => UserProfileSaved(userProfile: userProfile),
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
