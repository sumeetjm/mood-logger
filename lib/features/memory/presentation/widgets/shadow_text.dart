import 'dart:ui';

import 'package:flutter/material.dart';

class ShadowText extends StatelessWidget {
  ShadowText(this.data, {this.style, this.shadowColor = Colors.black})
      : assert(data != null);

  final String data;
  final TextStyle style;
  final Color shadowColor;

  Widget build(BuildContext context) {
    return new ClipRect(
      child: new Stack(
        children: [
          new Positioned(
            top: 2.0,
            left: 2.0,
            child: new Text(
              data,
              style: style.copyWith(color: shadowColor.withOpacity(0.5)),
            ),
          ),
          new Text(data, style: style),
        ],
      ),
    );
  }
}
