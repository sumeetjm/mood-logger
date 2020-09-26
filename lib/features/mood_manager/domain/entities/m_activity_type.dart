import 'package:flutter/material.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/base_m.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_activity.dart';

class MActivityType extends BaseM {
  final List<MActivity> mActivityList;
  MActivityType({
    String activityTypeId,
    @required String activityTypeName,
    @required String activityTypeCode,
    @required this.mActivityList,
    bool isActive = true,
  }) : super(
          id: activityTypeId,
          name: activityTypeName,
          code: activityTypeCode,
          isActive: isActive,
          className: 'mActivityType',
        );
}
