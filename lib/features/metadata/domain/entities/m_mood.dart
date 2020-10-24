import 'package:flutter/material.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';

class MMood extends Base {
  final String moodName;
  final String moodCode;
  final Color color;
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
