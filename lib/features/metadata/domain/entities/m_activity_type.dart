import 'package:flutter/material.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';

class MActivityType extends Base {
  String activityTypeName;
  String activityTypeCode;
  MActivityType({
    String activityTypeId,
    @required this.activityTypeName,
    @required this.activityTypeCode,
    bool isActive = true,
  }) : super(
          id: activityTypeId,
          isActive: isActive,
          className: 'mActivityType',
        );

  @override
  List<Object> get props =>
      [...super.props, activityTypeName, activityTypeCode];
}
