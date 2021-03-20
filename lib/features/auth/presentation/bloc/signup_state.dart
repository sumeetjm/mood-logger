part of 'signup_bloc.dart';

abstract class SignupState extends Equatable {
  const SignupState();

  @override
  List<Object> get props => [];
}

class SignupInitial extends SignupState {
  @override
  List<Object> get props => [];
}

class SignupSuccess extends SignupState {
  final FirebaseUser user;
  SignupSuccess({this.user}) : super();
  @override
  List<Object> get props => [user];
}

class SignupFailure extends SignupState {
  final String message;
  SignupFailure({this.message}) : super();
  @override
  List<Object> get props => [message];
}

class SignupLoading extends SignupState {}
