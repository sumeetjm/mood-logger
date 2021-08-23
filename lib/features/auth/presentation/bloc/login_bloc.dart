import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mood_manager/core/error/failures.dart';
import 'package:mood_manager/core/usecases/usecase.dart';
import 'package:mood_manager/features/auth/domain/entitles/user.dart';
import 'package:mood_manager/features/auth/domain/usecases/sign_in_with_credentials.dart';
import 'package:mood_manager/features/auth/domain/usecases/sign_in_with_facebook.dart';
import 'package:mood_manager/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:mood_manager/features/common/domain/entities/base_states.dart';

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
      yield LoginLoading();
      yield* _mapLoginWithGoogleRequestToState();
    } else if (event is LoginRequest) {
      yield LoginLoading();
      yield* _mapLoginRequestToState(event.user);
    } else if (event is LoginWithFacebookRequest) {
      yield LoginLoading();
      yield* _mapLoginWithFacebookRequestToState();
    }
  }

  Stream<LoginState> _mapLoginWithGoogleRequestToState() async* {
    final user = await signInWithGoogle(NoParams());
    yield user.fold((failure) => LoginFailure(message: failure.toString()),
        (user) => LoginSuccess(user: user));
  }

  Stream<LoginState> _mapLoginWithFacebookRequestToState() async* {
    final user = await signInWithFacebook(NoParams());
    yield user.fold((failure) => LoginFailure(message: failure.toString()),
        (user) => LoginSuccess(user: user));
  }

  Stream<LoginState> _mapLoginRequestToState(User user) async* {
    final loggedInuser = await signInWithCredentials(Params(user));
    yield loggedInuser.fold(
        (Failure failure) => LoginFailure(message: failure.toString()),
        (user) => LoginSuccess(user: user));
  }
}
