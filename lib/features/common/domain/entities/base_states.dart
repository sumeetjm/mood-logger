import 'dart:ui';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

class Started {}

class Loading {}

class Completed {}

void handleLoader(state, context) async {
  if (state is Loading) {
    await EasyLoading.show(
        status: "Loading...", maskType: EasyLoadingMaskType.black);
  } else if (state is Completed) {
    await EasyLoading.dismiss();
  }
}
