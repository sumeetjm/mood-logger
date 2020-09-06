import 'package:flutter/material.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/base_m.dart';

class MMood extends BaseM {
  final Color color;
  final List<MMood> mMoodList;

  MMood(
      {String moodId,
      String moodName,
      String moodCode,
      bool isActive,
      this.color,
      this.mMoodList})
      : super(id: moodId, name: moodName, code: moodCode, isActive: isActive);

  @override
  List<Object> get props => [color, mMoodList, ...super.props];
}
