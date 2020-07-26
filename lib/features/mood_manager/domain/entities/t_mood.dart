import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/base_t.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_activity.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_mood.dart';

class TMood extends BaseT {
  final String transMoodId;
  String note;
  final DateTime logDateTime;
  List<TActivity> tActivityList;
  MMood mMood;

  TMood(
      {this.transMoodId,
      DateTime auditDate,
      bool isActive,
      this.note,
      @required this.logDateTime,
      this.tActivityList,
      this.mMood})
      : super(auditDate: auditDate, isActive: isActive);

  set setTActivityList(List<TActivity> tActivityList) {
    this.tActivityList = tActivityList;
  }

  set setNote(String note) {
    this.note = note;
  }

  @override
  List<Object> get props =>
      [transMoodId, note, logDateTime, tActivityList, mMood, ...super.props];
}
