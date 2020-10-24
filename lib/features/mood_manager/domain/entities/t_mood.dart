import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/base.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_mood.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_activity.dart';

class TMood extends Base {
  final String note;
  final DateTime logDateTime;
  final MMood mMood;
  final List<TActivity> tActivityList;
  final DateTime auditDate;

  TMood({
    String id,
    @required this.note,
    @required this.logDateTime,
    @required this.mMood,
    @required this.tActivityList,
    this.auditDate,
    bool isActive = true,
  }) : super(
          id: id,
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
