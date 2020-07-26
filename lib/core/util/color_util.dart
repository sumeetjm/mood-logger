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
}
