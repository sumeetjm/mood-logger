import 'package:flutter/material.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:hive/hive.dart';
import 'package:mood_manager/features/metadata/data/models/m_mood_parse.dart';
import 'package:mood_manager/core/util/hex_color.dart';

part 'm_mood.g.dart';

@HiveType(typeId: 0)
class MMood extends Base {
  @HiveField(3)
  final String moodName;
  @HiveField(4)
  final String moodCode;
  @HiveField(5)
  final Color color;
  @HiveField(6)
  final List<MMood> mMoodList;

  MMood({
    String moodId,
    @required this.moodName,
    @required this.moodCode,
    bool isActive = true,
    @required this.color,
    @required this.mMoodList,
  }) : super(
          id: moodId,
          isActive: isActive,
          className: 'mMood',
        );
}
