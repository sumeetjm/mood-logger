part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class GetCurrentUserProfileEvent extends ProfileEvent {}

class GetUserProfileEvent extends ProfileEvent {
  final User user;
  GetUserProfileEvent(this.user);

  @override
  List<Object> get props => [user];
}

class SaveUserProfileEvent extends ProfileEvent {
  final UserProfile userProfile;
  SaveUserProfileEvent(this.userProfile);

  @override
  List<Object> get props => [userProfile];
}

class SaveProfilePictureEvent extends ProfileEvent {
  final MediaCollectionMapping profilePictureMediaCollection;
  final UserProfile userProfile;
  SaveProfilePictureEvent(this.profilePictureMediaCollection, this.userProfile);

  @override
  List<Object> get props => [profilePictureMediaCollection, userProfile];
}
