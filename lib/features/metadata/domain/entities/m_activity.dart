import 'package:flutter/material.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity_type.dart';

class MActivity extends Base {
  final String activityName;
  final String activityCode;
  final MActivityType mActivityType;
  MActivity({
    String activityId,
    @required this.activityName,
    @required this.activityCode,
    bool isActive = true,
    @required this.mActivityType,
  }) : super(
          id: activityId,
          isActive: isActive,
          className: 'mActivity',
        );

  @override
  List<Object> get props =>
      [...super.props, activityCode, activityName, mActivityType];
}
