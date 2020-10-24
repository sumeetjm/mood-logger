import 'package:flutter/material.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/base.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_activity_type.dart';

class MActivity extends Base {
  final String activityName;
  final String activityCode;
  MActivityType mActivityType;
  MActivity({
    String activityId,
    @required this.activityName,
    @required this.activityCode,
    bool isActive = true,
  }) : super(
          id: activityId,
          isActive: isActive,
          className: 'mActivity',
        );

  @override
  List<Object> get props => [...super.props, activityCode, activityName];
}
