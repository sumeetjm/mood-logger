import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mood_manager/core/error/failures.dart';
import 'package:mood_manager/core/usecases/usecase.dart';
import 'package:mood_manager/features/auth/domain/entitles/user.dart';
import 'package:mood_manager/features/common/domain/entities/base_states.dart';
import 'package:mood_manager/features/common/domain/entities/media.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection_mapping.dart';
import 'package:mood_manager/features/profile/domain/entities/user_profile.dart';
import 'package:mood_manager/features/profile/domain/usecases/get_current_user_profile.dart';
import 'package:mood_manager/features/profile/domain/usecases/get_user_profile.dart';
import 'package:mood_manager/features/profile/domain/usecases/link_with_social.dart';
import 'package:mood_manager/features/profile/domain/usecases/save_profile_picture.dart';
import 'package:mood_manager/features/profile/domain/usecases/save_user_profile.dart';
import 'package:mood_manager/features/mood_manager/presentation/bloc/activity_list_bloc.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetCurrentUserProfile getCurrentUserProfile;
  final GetUserProfile getUserProfile;
  final SaveUserProfile saveUserProfile;
  final SaveProfilePicture saveProfilePicture;
  final LinkWithSocial linkWithSocial;

  ProfileBloc({
    this.getCurrentUserProfile,
    this.getUserProfile,
    this.saveUserProfile,
    this.saveProfilePicture,
    this.linkWithSocial,
  }) : super(ProfileInitial());

  @override
  Stream<ProfileState> mapEventToState(
    ProfileEvent event,
  ) async* {
    if (event is GetCurrentUserProfileEvent) {
      yield UserProfileLoading();
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
    } else if (event is SaveProfilePictureEvent) {
      yield ProfilePictureSaving(
          photo: event.profilePictureMediaCollection.media);
      await saveProfilePicture(Params(
          MapEntry(event.profilePictureMediaCollection, event.userProfile)));
      final either = await getCurrentUserProfile(NoParams());
      yield* _eitherUserProfileSavedOrErrorState(either);
    } else if (event is LinkWithSocialEvent) {
      yield UserProfileLoading();
      final either = await linkWithSocial(Params(event.social));
      yield* _eitherSocialLinkedOrErrorState(either);
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

  Stream<ProfileState> _eitherSocialLinkedOrErrorState(
    Either<Failure, String> failureOrMoodList,
  ) async* {
    yield failureOrMoodList.fold(
      (failure) => UserProfileError(message: _mapFailureToMessage(failure)),
      (userProfile) => LinkedWithSocial(userProfile),
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
