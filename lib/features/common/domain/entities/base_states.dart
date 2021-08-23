import 'package:flutter_easyloading/flutter_easyloading.dart';

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

Future<T> handleFuture<T>(Function futureFn) async {
  await EasyLoading.show(
      status: "Loading...", maskType: EasyLoadingMaskType.black);
  final result = await futureFn();
  await EasyLoading.dismiss();
  return result;
}
