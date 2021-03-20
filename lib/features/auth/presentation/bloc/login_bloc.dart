import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mood_manager/core/usecases/usecase.dart';
import 'package:mood_manager/features/auth/domain/entitles/user.dart';
import 'package:mood_manager/features/auth/domain/usecases/sign_in_with_credentials.dart';
import 'package:mood_manager/features/auth/domain/usecases/sign_in_with_facebook.dart';
import 'package:mood_manager/features/auth/domain/usecases/sign_in_with_google.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final SignInWithCredentials signInWithCredentials;
  final SignInWithGoogle signInWithGoogle;
  final SignInWithFacebook signInWithFacebook;

  LoginBloc(
      {SignInWithCredentials signInWithCredentials,
      SignInWithGoogle signInWithGoogle,
      SignInWithFacebook signInWithFacebook})
      : assert(signInWithCredentials != null),
        assert(signInWithGoogle != null),
        this.signInWithCredentials = signInWithCredentials,
        this.signInWithGoogle = signInWithGoogle,
        this.signInWithFacebook = signInWithFacebook,
        super(LoginInitial());

  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    if (event is LoginWithGoogleRequest) {
      yield* _mapLoginWithGoogleRequestToState();
    } else if (event is LoginRequest) {
      yield* _mapLoginRequestToState(event.user);
    } else if (event is LoginWithFacebookRequest) {
      yield* _mapLoginWithFacebookRequestToState();
    }
  }

  Stream<LoginState> _mapLoginWithGoogleRequestToState() async* {
    final user = await signInWithGoogle(NoParams());
    yield user.fold(
        (failure) => LoginFailure(), (user) => LoginSuccess(user: user));
  }

  Stream<LoginState> _mapLoginWithFacebookRequestToState() async* {
    final user = await signInWithFacebook(NoParams());
    yield user.fold(
        (failure) => LoginFailure(), (user) => LoginSuccess(user: user));
  }

  Stream<LoginState> _mapLoginRequestToState(User user) async* {
    yield LoginLoading();
    final loggedInuser = await signInWithCredentials(Params(user));
    yield loggedInuser.fold(
        (dynamic failure) => LoginFailure(message: failure.message),
        (user) => LoginSuccess(user: user));
  }
}
