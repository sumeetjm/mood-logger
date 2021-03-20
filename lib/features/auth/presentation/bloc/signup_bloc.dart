import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mood_manager/core/usecases/usecase.dart';
import 'package:mood_manager/features/auth/domain/entitles/user.dart';
import 'package:mood_manager/features/auth/domain/usecases/is_username_exist.dart';
import 'package:mood_manager/features/auth/domain/usecases/is_user_exist.dart';
import 'package:mood_manager/features/auth/domain/usecases/sign_up.dart';

part 'signup_event.dart';
part 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final SignUp signUp;
  final IsUserExist isUserExist;
  final IsUsernameExist isUsernameExist;

  SignupBloc({
    SignUp signUp,
    IsUserExist isUserExist,
    IsUsernameExist isUsernameExist,
  })  : assert(signUp != null),
        assert(isUserExist != null),
        assert(isUsernameExist != null),
        this.signUp = signUp,
        this.isUserExist = isUserExist,
        this.isUsernameExist = isUsernameExist,
        super(SignupInitial());

  @override
  Stream<SignupState> mapEventToState(
    SignupEvent event,
  ) async* {
    if (event is SignupRequest) {
      yield* _validateAndMapSignupRequestToState(event.user);
    }
  }

  Stream<SignupState> _mapSignupRequestToState(User user) async* {
    final either = await signUp(Params(user));
    yield either.fold(
        (dynamic failure) => SignupFailure(message: failure.message),
        (_) => SignupSuccess());
  }

  Stream<SignupState> _validateAndMapSignupRequestToState(User user) async* {
    SignupState state = SignupLoading();
    yield state;
    Either either = await isUserExist(Params(user));
    state = either.fold(
        (failure) => SignupFailure(message: failure.toString()),
        (isUserExist) => isUserExist
            ? SignupFailure(message: 'User already exist')
            : SignupLoading());
    yield state;
    if (either.isLeft()) return;
    either = await isUsernameExist(Params(user));
    state = either.fold(
        (failure) => SignupFailure(message: failure.toString()),
        (isUserExist) => isUserExist
            ? SignupFailure(message: 'Username already taken')
            : SignupLoading());
    yield state;
    if (either.isLeft()) return;
    yield* _mapSignupRequestToState(user);
  }
}
