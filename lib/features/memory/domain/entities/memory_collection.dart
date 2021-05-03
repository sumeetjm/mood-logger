import 'package:flutter/material.dart';
import 'package:mood_manager/core/util/color_util.dart';
import 'package:mood_manager/core/util/hex_color.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/memory/data/models/memory_collection_parse.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:hive/hive.dart';

part 'memory_collection.g.dart';

// ignore: must_be_immutable
@HiveType(typeId: 7)
class MemoryCollection extends Base {
  @HiveField(3)
  String name;
  @HiveField(4)
  final String code;
  @HiveField(5)
  Color averageMemoryMoodColor;
  @HiveField(6)
  int memoryCount;
  ParseUser user;
  MemoryCollection({
    String id,
    this.name,
    this.code,
    bool isActive = true,
    this.averageMemoryMoodColor,
    this.memoryCount,
    this.user,
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
