part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent([List props = const []]);
  List<Object> get props => props;
}

class LoginRequest extends LoginEvent {
  final User user;
  LoginRequest({this.user}) : super([user]);
}

class LoginWithGoogleRequest extends LoginEvent {}

class LoginWithFacebookRequest extends LoginEvent {}
