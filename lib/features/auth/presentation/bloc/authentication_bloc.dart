import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mood_manager/core/usecases/usecase.dart';
import 'package:mood_manager/features/auth/domain/usecases/get_current_user.dart';
import 'package:mood_manager/features/auth/domain/usecases/is_signed_in.dart';
import 'package:mood_manager/features/auth/domain/usecases/sign_out.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final IsSignedIn isSignedIn;
  final GetCurrentUser getCurrentUser;
  final SignOut signOut;

  AuthenticationBloc(
      {@required IsSignedIn isSignedIn,
      @required GetCurrentUser getCurrentUser,
      @required SignOut signOut})
      : assert(isSignedIn != null),
        assert(getCurrentUser != null),
        assert(signOut != null),
        this.isSignedIn = isSignedIn,
        this.getCurrentUser = getCurrentUser,
        this.signOut = signOut,
        super(AuthenticationInitial());

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AppStarted) {
      yield* _mapAppStartedToState();
    } else if (event is LoggedIn) {
      yield* _mapLoggedInToState();
    } else if (event is LoggedOut) {
      yield* _mapLoggedOutToState();
    }
  }

  Stream<AuthenticationState> _mapAppStartedToState() async* {
    final isAuthenticated = await isSignedIn(NoParams());
    yield* isAuthenticated.fold((failure) => Stream.value(Unauthenticated()),
        (isAuthenticated) => _mapAuthOrUnAuth(isAuthenticated));
  }

  Stream<AuthenticationState> _mapAuthOrUnAuth(final bool isAuth) async* {
    if (isAuth) {
      final user = await getCurrentUser(NoParams());
      yield await user.fold(
          (failure) => Unauthenticated(), (user) => Authenticated(user.email));
    } else {
      yield Unauthenticated();
    }
  }

  Stream<AuthenticationState> _mapLoggedInToState() async* {
    final mayBeUser = await getCurrentUser(NoParams());
    yield mayBeUser.fold(
        (failure) => Unauthenticated(), (user) => Authenticated(user.email));
  }

  Stream<AuthenticationState> _mapLoggedOutToState() async* {
    yield Unauthenticated();
    await signOut(NoParams());
  }
}
