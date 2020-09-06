import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mood_manager/core/usecases/usecase.dart';
import 'package:mood_manager/features/auth/domain/entitles/user.dart';
import 'package:mood_manager/features/auth/domain/usecases/sign_up.dart';

part 'signup_event.dart';
part 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final SignUp signUp;

  SignupBloc({SignUp signUp})
      : assert(signUp != null),
        this.signUp = signUp,
        super(SignupInitial());

  @override
  Stream<SignupState> mapEventToState(
    SignupEvent event,
  ) async* {
    if (event is SignupRequest) {
      yield* _mapSignupRequestToState(event.user);
    }
  }

  Stream<SignupState> _mapSignupRequestToState(User user) async* {
    yield SignupLoading();
    final either = await signUp(Params(user));
    yield either.fold((failure) => SignupFailure(), (_) => SignupSuccess());
  }
}
