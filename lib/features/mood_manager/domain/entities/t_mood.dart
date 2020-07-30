import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/base_t.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_mood.dart';

class TMood extends BaseT {
  String note;
  final DateTime logDateTime;
  MMood mMood;

  TMood(
      {String id,
      DateTime auditDate,
      bool isActive,
      this.note,
      @required this.logDateTime,
      this.mMood})
      : super(id: id, auditDate: auditDate, isActive: isActive);

  set setNote(String note) {
    this.note = note;
  }

  @override
  List<Object> get props => [note, logDateTime, mMood, ...super.props];
}
