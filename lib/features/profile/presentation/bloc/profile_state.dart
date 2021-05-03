part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class UserProfileLoading extends ProfileState with Loading {}

class UserProfileLoaded extends ProfileState with Completed {
  final UserProfile userProfile;

  UserProfileLoaded({this.userProfile});

  @override
  List<Object> get props => [userProfile];
}

class UserProfileError extends ProfileState with Completed {
  final String message;

  UserProfileError({this.message});

  @override
  List<Object> get props => [message];
}

class UserProfileSaved extends ProfileState with Completed {
  final UserProfile userProfile;

  UserProfileSaved({this.userProfile});

  @override
  List<Object> get props => [userProfile];
}

class UserProfileSaving extends ProfileState with Loading {
  final UserProfile userProfile;

  UserProfileSaving({this.userProfile});

  @override
  List<Object> get props => [userProfile];
}

class ProfilePictureSaving extends ProfileState with Loading {
  final Media photo;

  ProfilePictureSaving({this.photo});

  @override
  List<Object> get props => [photo];
}

class LinkedWithSocial extends ProfileState with Completed {
  final String social;
  LinkedWithSocial(this.social);

  @override
  List<Object> get props => [social];
}
