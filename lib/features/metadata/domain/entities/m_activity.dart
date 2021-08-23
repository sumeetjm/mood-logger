import 'package:flutter/material.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/metadata/data/models/m_activity_parse.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity_type.dart';
import 'package:hive/hive.dart';

part 'm_activity.g.dart';

@HiveType(typeId: 1)
class MActivity extends Base {
  @HiveField(3)
  final String activityName;
  @HiveField(4)
  final String activityCode;
  @HiveField(5)
  final MActivityType mActivityType;
  @HiveField(6)
  final Map userPtr;
  MActivity({
    this.userPtr,
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
