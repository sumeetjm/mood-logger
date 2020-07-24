import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/base_m.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_activity_type.dart';

class MActivity extends BaseM {
  final MActivityType mActivityType;

  MActivity({
    activityId,
    activityName,
    activityCode,
    isActive = true,
    @required this.mActivityType,
  }) : super(
            id: activityId,
            name: activityName,
            code: activityCode,
            isActive: isActive);

  @override
  List<Object> get props => [id, name, code, isActive];
}
