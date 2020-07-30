import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mood_manager/features/mood_manager/data/models/m_activity_type_model.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_activity.dart';

class MActivityModel extends MActivity {
  MActivityModel(
      {String activityId,
      String activityName,
      String activityCode,
      MActivityTypeModel mActivityTypeModel,
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

  factory MActivityModel.fromFirestore(DocumentSnapshot doc) {
    if (doc == null) {
      return null;
    }
    //debugger(when: false);
    return MActivityModel(
        activityId: doc.documentID,
        activityName: doc['name'],
        activityCode: doc['code'],
        isActive: doc['isActive'],
        mActivityTypeModel: MActivityTypeModel.fromId(
            (doc['mActivityType'] as DocumentReference).documentID));
    /*mActivityTypeModel:
            MActivityTypeModel.fromFirestore(doc['mActivityType']));*/
  }

  factory MActivityModel.fromId(String activityId) {
    return MActivityModel(activityId: activityId);
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

  static List<MActivity> fromJsonArray(List<dynamic> jsonArray) {
    return jsonArray.map((json) => MActivityModel.fromJson(json)).toList();
  }

  static Map<String, List<MActivity>> fromJsonGroupedByType(
      Map<String, dynamic> json) {
    return Map.fromEntries(json.entries.map((e) => MapEntry(e.key,
        (e.value as List).map((e) => MActivityModel.fromJson(e)).toList())));
  }

  static Map<String, List<MActivity>> groupedByType(
      List<MActivity> activityList) {
    List<String> mActivityTypeCodeList =
        activityList.map((e) => e.mActivityType.code).toSet().toList();
    return Map.fromEntries(mActivityTypeCodeList.map((e) => MapEntry(
        e, activityList.where((element) => element.mActivityType.code == e))));
  }

  factory MActivityModel.initial() {
    return MActivityModel(
        activityId: '',
        activityCode: '',
        activityName: '',
        isActive: true,
        mActivityTypeModel: MActivityTypeModel.initial());
  }
}
