import 'package:flutter/material.dart';

class LoadingBar extends StatelessWidget {
  final bool isLoading;
  LoadingBar(this.isLoading);
  @override
  Widget build(BuildContext context) {
    //debugger();
    return Container(
      height: 5,
      child: Visibility(
          visible: isLoading, child: Image.asset('assets/loading_bar.gif')),
    );
  }
}
