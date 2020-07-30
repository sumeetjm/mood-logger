import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mood_manager/core/usecases/usecase.dart';
import 'package:mood_manager/features/auth/domain/entitles/user_credenial.dart';
import 'package:mood_manager/features/auth/domain/usecases/sign_in_with_credentials.dart';
import 'package:mood_manager/features/auth/domain/usecases/sign_in_with_google.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final SignInWithCredentials signInWithCredentials;
  final SignInWithGoogle signInWithGoogle;

  LoginBloc(
      {SignInWithCredentials signInWithCredentials,
      SignInWithGoogle signInWithGoogle})
      : assert(signInWithCredentials != null),
        assert(signInWithGoogle != null),
        this.signInWithCredentials = signInWithCredentials,
        this.signInWithGoogle = signInWithGoogle,
        super(LoginInitial());

  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    //debugger(when: false);
    if (event is LoginWithGoogleRequest) {
      yield* _mapLoginWithGoogleRequestToState();
    } else if (event is LoginRequest) {
      yield* _mapLoginRequestToState(event.userCredential);
    }
  }

  Stream<LoginState> _mapLoginWithGoogleRequestToState() async* {
    final user = await signInWithGoogle(NoParams());
    yield user.fold(
        (failure) => LoginFailure(), (user) => LoginSuccess(user: user));
  }

  Stream<LoginState> _mapLoginRequestToState(
      UserCredential userCredential) async* {
    yield LoginLoading();
    final user = await signInWithCredentials(Params(userCredential));
    yield user.fold(
        (failure) => LoginFailure(), (user) => LoginSuccess(user: user));
  }
}
