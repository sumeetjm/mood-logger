import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:flutter/material.dart';

class Started {}

class Loading {}

class Completed {}

void handleLoader(state, context) {
  if (state is Loading) {
    Loader.show(context,
        overlayColor: Colors.black.withOpacity(0.5),
        isAppbarOverlay: true,
        isBottomBarOverlay: true,
        progressIndicator: RefreshProgressIndicator());
  } else if (state is Completed) {
    Loader.hide();
  }
}
