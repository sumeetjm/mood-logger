import 'dart:math';

import 'package:flutter/material.dart';

class ColorUtil {
  static Color mix(List<Color> colors) {
    if (colors.isEmpty) {
      return Colors.white;
    }
    return Color.fromRGBO(
        colors
                .map((color) => color.red)
                .reduce((value, element) => value + element) ~/
            colors.length,
        colors
                .map((color) => color.green)
                .reduce((value, element) => value + element) ~/
            colors.length,
        colors
                .map((color) => color.blue)
                .reduce((value, element) => value + element) ~/
            colors.length,
        1);
  }

  static Color get random =>
      Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
}
