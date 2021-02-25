import 'dart:math';

import 'package:flutter/material.dart';

class ColorUtil {
  static Color mix(List<Color> colors) {
    if (colors.isEmpty) {
      return Colors.white;
    }
    final colorList = colors.where((element) => element != null).toList();
    return Color.fromRGBO(
        colorList
                .map((color) => color.red)
                .reduce((value, element) => value + element) ~/
            colorList.length,
        colorList
                .map((color) => color.green)
                .reduce((value, element) => value + element) ~/
            colorList.length,
        colorList
                .map((color) => color.blue)
                .reduce((value, element) => value + element) ~/
            colorList.length,
        1);
  }

  static Color unmix(List<Color> colors) {
    if (colors.isEmpty) {
      return Colors.white;
    }
    final colorList = colors.where((element) => element != null).toList();
    return Color.fromRGBO(
        colorList
                .map((color) => color.red)
                .reduce((value, element) => value - element) ~/
            colorList.length,
        colorList
                .map((color) => color.green)
                .reduce((value, element) => value - element) ~/
            colorList.length,
        colorList
                .map((color) => color.blue)
                .reduce((value, element) => value - element) ~/
            colorList.length,
        1);
  }

  static Color get random =>
      Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
}
