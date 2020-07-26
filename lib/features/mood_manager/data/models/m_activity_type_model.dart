import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mood_manager/features/mood_manager/domain/entities/m_activity_type.dart';

class MActivityTypeModel extends MActivityType {
  MActivityTypeModel({
    String activityTypeId,
    String activityTypeName,
    String activityTypeCode,
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

  factory MActivityTypeModel.fromId(String activityTypeId) {
    return MActivityTypeModel(activityTypeId: activityTypeId);
  }

  factory MActivityTypeModel.fromFirestore(DocumentSnapshot doc) {
    if (doc == null) {
      return null;
    }
    debugger(when: false);
    return MActivityTypeModel(
        activityTypeId: doc.documentID,
        activityTypeName: doc['name'],
        activityTypeCode: doc['code'],
        isActive: doc['isActive']);
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
