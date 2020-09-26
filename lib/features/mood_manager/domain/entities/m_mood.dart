import 'package:flutter/material.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/base_m.dart';

class MMood extends BaseM {
  final Color color;
  final List<MMood> mMoodList;

  MMood({
    String moodId,
    @required String moodName,
    @required String moodCode,
    bool isActive = true,
    @required this.color,
    @required this.mMoodList,
  }) : super(
          id: moodId,
          name: moodName,
          code: moodCode,
          isActive: isActive,
          className: 'mMood',
        );
}
