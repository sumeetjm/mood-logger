part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class UserProfileLoading extends ProfileState {}

class UserProfileLoaded extends ProfileState {
  final UserProfile userProfile;

  UserProfileLoaded({this.userProfile});

  @override
  List<Object> get props => [userProfile];
}

class UserProfileError extends ProfileState {
  final String message;

  UserProfileError({this.message});

  @override
  List<Object> get props => [message];
}

class UserProfileSaved extends ProfileState {
  final UserProfile userProfile;

  UserProfileSaved({this.userProfile});

  @override
  List<Object> get props => [userProfile];
}

class UserProfileSaving extends ProfileState {
  final UserProfile userProfile;

  UserProfileSaving({this.userProfile});

  @override
  List<Object> get props => [userProfile];
}

class ProfilePictureSaving extends ProfileState {
  final Media photo;

  ProfilePictureSaving({this.photo});

  @override
  List<Object> get props => [photo];
}
