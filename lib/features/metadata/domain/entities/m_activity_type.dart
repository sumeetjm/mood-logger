import 'package:flutter/material.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:hive/hive.dart';
import 'package:mood_manager/features/metadata/data/models/m_activity_type_parse.dart';

part 'm_activity_type.g.dart';

@HiveType(typeId: 2)
class MActivityType extends Base {
  @HiveField(3)
  String activityTypeName;
  @HiveField(4)
  String activityTypeCode;
  @HiveField(5)
  Map userPtr;
  MActivityType({
    String activityTypeId,
    @required this.activityTypeName,
    @required this.activityTypeCode,
    @required this.userPtr,
    bool isActive = true,
  }) : super(
          id: activityTypeId,
          isActive: isActive,
          className: 'mActivityType',
        );

  @override
  List<Object> get props =>
      [...super.props, activityTypeName, activityTypeCode, userPtr];
}
