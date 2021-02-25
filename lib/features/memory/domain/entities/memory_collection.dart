import 'package:flutter/material.dart';
import 'package:mood_manager/core/util/color_util.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';

// ignore: must_be_immutable
class MemoryCollection extends Base {
  String name;
  final String code;
  Color averageMemoryMoodColor;
  int memoryCount;
  MemoryCollection({
    String id,
    this.name,
    this.code,
    bool isActive = true,
    this.averageMemoryMoodColor,
    this.memoryCount,
  }) : super(
          id: id,
          isActive: isActive,
          className: 'memoryCollection',
        );

  MemoryCollection incrementMemoryCount() {
    memoryCount++;
    return this;
  }

  MemoryCollection decrementMemoryCount() {
    memoryCount--;
    return this;
  }

  MemoryCollection addColor(Color color) {
    averageMemoryMoodColor = ColorUtil.mix([averageMemoryMoodColor, color]);
    return this;
  }

  MemoryCollection removeColor(Color color) {
    averageMemoryMoodColor = ColorUtil.mix([averageMemoryMoodColor, color]);
    return this;
  }

  @override
  List<Object> get props => [name, code, ...super.props];
}