part of 'signup_bloc.dart';

abstract class SignupEvent extends Equatable {
  const SignupEvent([List props = const []]);
  List<Object> get props => props;
}

class SignupRequest extends SignupEvent {
  final UserCredential userCredential;
  SignupRequest({this.userCredential}) : super([userCredential]);
}
