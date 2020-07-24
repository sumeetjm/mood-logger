import 'dart:async';

import 'package:bloc/bloc.dart';

class ResourceUtil {
  static closeBloc(Bloc bloc) {
    if (bloc != null) {
      bloc.close();
    }
  }

  static closeSubscription(StreamSubscription subscription) {
    if (subscription != null) {
      subscription.cancel();
    }
  }
}
