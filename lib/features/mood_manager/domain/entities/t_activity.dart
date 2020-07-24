import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/base_t.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_activity.dart';

class TActivity extends BaseT {
  final int transActivityId;
  final String activityCode;
  final String activityName;
  final MActivity mActivity;

  TActivity(
      {this.transActivityId,
      DateTime auditDate,
      bool isActive,
      @required this.activityCode,
      @required this.activityName,
      this.mActivity})
      : super(auditDate: auditDate, isActive: isActive);

  @override
  List<Object> get props => [transActivityId, activityCode, activityName];
}
