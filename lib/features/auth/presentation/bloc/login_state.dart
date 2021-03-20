part of 'login_bloc.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {
  @override
  List<Object> get props => [];
}

class LoginSuccess extends LoginState {
  final User user;
  LoginSuccess({this.user}) : super();
  @override
  List<Object> get props => [user];
}

class LoginFailure extends LoginState {
  final String message;
  LoginFailure({this.message}) : super();
  @override
  List<Object> get props => [message];
}

class LoginLoading extends LoginState {}
