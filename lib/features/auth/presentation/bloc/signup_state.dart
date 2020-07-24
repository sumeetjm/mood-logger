part of 'signup_bloc.dart';

abstract class SignupState extends Equatable {
  const SignupState([List props = const []]);

  @override
  List<Object> get props => props;
}

class SignupInitial extends SignupState {
  @override
  List<Object> get props => [];
}

class SignupSuccess extends SignupState {
  final FirebaseUser user;
  SignupSuccess({this.user}) : super([user]);
}

class SignupFailure extends SignupState {
  final String message;
  SignupFailure({this.message}) : super([message]);
}

class SignupLoading extends SignupState {}
