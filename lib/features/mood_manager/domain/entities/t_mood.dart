import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/base_t.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_mood.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_activity.dart';

class TMood extends BaseT {
  final String note;
  final DateTime logDateTime;
  final MMood mMood;
  final List<TActivity> tActivityList;

  TMood({
    String id,
    DateTime auditDate,
    bool isActive = true,
    @required this.note,
    @required this.logDateTime,
    @required this.mMood,
    @required this.tActivityList,
  }) : super(
          id: id,
          auditDate: auditDate,
          isActive: isActive,
          className: 'tMood',
        );

  @override
  List<Object> get props => [
        note,
        logDateTime,
        mMood,
        tActivityList,
        ...super.props,
      ];
}
