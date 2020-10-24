import 'package:flutter/material.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity.dart';

class MActivityType extends Base {
  final List<MActivity> mActivityList;
  final String activityTypeName;
  final String activityTypeCode;
  MActivityType({
    String activityTypeId,
    @required this.activityTypeName,
    @required this.activityTypeCode,
    @required this.mActivityList,
    bool isActive = true,
  }) : super(
          id: activityTypeId,
          isActive: isActive,
          className: 'mActivityType',
        );

  @override
  // TODO: implement props
  List<Object> get props =>
      [...super.props, activityTypeName, activityTypeCode];
}
