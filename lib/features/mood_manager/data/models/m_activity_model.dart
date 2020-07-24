import 'package:mood_manager/features/mood_manager/data/models/m_activity_type_model.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_activity.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class MActivityModel extends MActivity {
  MActivityModel(
      {@required int activityId,
      @required String activityName,
      @required String activityCode,
      @required MActivityTypeModel mActivityTypeModel,
      bool isActive = true})
      : super(
            activityId: activityId,
            activityName: activityName,
            activityCode: activityCode,
            mActivityType: mActivityTypeModel,
            isActive: isActive);

  factory MActivityModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return MActivityModel(
        activityId: json['id'],
        activityName: json['name'],
        activityCode: json['code'],
        isActive: json['isActive'],
        mActivityTypeModel: MActivityTypeModel.fromJson(json['mactivityType']));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'isActive': isActive,
      'mactivityType': mActivityType
    };
  }

  static List<MActivityModel> fromJsonArray(List<dynamic> jsonArray) {
    return jsonArray.map((json) => MActivityModel.fromJson(json)).toList();
  }

  static Map<String, List<MActivityModel>> fromJsonGroupedByType(
      Map<String, dynamic> json) {
    return Map.fromEntries(json.entries.map((e) => MapEntry(e.key,
        (e.value as List).map((e) => MActivityModel.fromJson(e)).toList())));
  }
}
