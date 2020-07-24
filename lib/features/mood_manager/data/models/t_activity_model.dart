import 'package:mood_manager/features/mood_manager/data/models/m_activity_model.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_activity.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class TActivityModel extends TActivity {
  TActivityModel(
      {int transActivityId,
      @required String activityName,
      @required String activityCode,
      MActivityModel mActivityModel,
      bool isActive = true})
      : super(
            transActivityId: transActivityId,
            activityName: activityName,
            activityCode: activityCode,
            mActivity: mActivityModel,
            isActive: isActive);

  factory TActivityModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return TActivityModel(
        transActivityId: json['transActivityId'],
        activityName: json['activityName'],
        activityCode: json['activityCode'],
        mActivityModel: MActivityModel.fromJson(json['mactivity']),
        isActive: json['isActive']);
  }

  static List<TActivityModel> fromJsonArray(List<dynamic> jsonArray) {
    return jsonArray.map((json) => TActivityModel.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'transActivityId': transActivityId,
      'activityName': activityName,
      'activityCode': activityCode,
      'mactivity': (mActivity as MActivityModel).toJson(),
      'isActive': isActive
    };
  }
}
