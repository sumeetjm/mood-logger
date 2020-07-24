import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'package:mood_manager/features/mood_manager/domain/entities/m_activity_type.dart';

class MActivityTypeModel extends MActivityType {
  MActivityTypeModel({
    @required int activityTypeId,
    @required String activityTypeName,
    @required String activityTypeCode,
    bool isActive = true,
  }) : super(
            activityTypeId: activityTypeId,
            activityTypeName: activityTypeCode,
            activityTypeCode: activityTypeCode,
            isActive: isActive);

  factory MActivityTypeModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return MActivityTypeModel(
        activityTypeId: json['id'],
        activityTypeName: json['name'],
        activityTypeCode: json['code'],
        isActive: json['isActive']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'isActive': isActive,
    };
  }
}
