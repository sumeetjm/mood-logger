import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/base_t.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_activity.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_mood.dart';

class TMood extends BaseT {
  final int transMoodId;
  final String moodCode;
  final String moodName;
  final String note;
  final DateTime logDateTime;
  final List<TActivity> tActivityList;
  final MMood mMood;

  TMood(
      {this.transMoodId,
      DateTime auditDate,
      bool isActive,
      @required this.moodCode,
      @required this.moodName,
      this.note,
      @required this.logDateTime,
      this.tActivityList,
      this.mMood})
      : super(auditDate: auditDate, isActive: isActive);

  @override
  List<Object> get props => [
        transMoodId,
        moodCode,
        moodName,
        note,
        logDateTime,
      ];
}
