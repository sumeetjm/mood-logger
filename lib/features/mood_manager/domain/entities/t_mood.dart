import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/base_t.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_mood.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_activity.dart';

class TMood extends BaseT {
  String note;
  final DateTime logDateTime;
  MMood mMood;
  List<TActivity> tActivityList;

  TMood(
      {String id,
      DateTime auditDate,
      bool isActive,
      this.note,
      @required this.logDateTime,
      this.mMood,
      this.tActivityList})
      : super(
          id: id,
          auditDate: auditDate,
          isActive: isActive,
        );

  set setNote(String note) => this.note = note;

  @override
  List<Object> get props =>
      [note, logDateTime, mMood, tActivityList, ...super.props];
}
