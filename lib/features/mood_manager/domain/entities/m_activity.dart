import 'package:flutter/material.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/base_m.dart';

class MActivity extends BaseM {
  MActivity({
    String activityId,
    @required String activityName,
    @required String activityCode,
    bool isActive = true,
  }) : super(
          id: activityId,
          name: activityName,
          code: activityCode,
          isActive: isActive,
          className: 'mActivity',
        );
}
