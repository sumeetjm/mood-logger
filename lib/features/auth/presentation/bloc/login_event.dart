part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent([List props = const []]);
  List<Object> get props => props;
}

class LoginRequest extends LoginEvent {
  final UserCredential userCredential;
  LoginRequest({this.userCredential}) : super([userCredential]);
}

class LoginWithGoogleRequest extends LoginEvent {}
