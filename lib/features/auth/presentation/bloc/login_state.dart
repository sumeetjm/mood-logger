part of 'login_bloc.dart';

abstract class LoginState extends Equatable {
  const LoginState([List props = const []]);

  @override
  List<Object> get props => props;
}

class LoginInitial extends LoginState {
  @override
  List<Object> get props => [];
}

class LoginSuccess extends LoginState {
  final FirebaseUser user;
  LoginSuccess({this.user}) : super([user]);
}

class LoginFailure extends LoginState {
  final String message;
  LoginFailure({this.message}) : super([message]);
}

class LoginLoading extends LoginState {}
