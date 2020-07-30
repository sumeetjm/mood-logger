import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mood_manager/features/mood_manager/data/models/m_activity_model.dart';
import 'package:mood_manager/features/mood_manager/data/models/t_mood_model.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_activity.dart';

class TActivityModel extends TActivity {
  TActivityModel(
      {String transActivityId,
      MActivityModel mActivityModel,
      bool isActive = true,
      TMoodModel tMoodModel})
      : super(
            id: transActivityId,
            mActivity: mActivityModel,
            isActive: isActive,
            tMood: tMoodModel);

  factory TActivityModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return TActivityModel(
        transActivityId: json['transActivityId'],
        mActivityModel: MActivityModel.fromJson(json['mactivity']),
        isActive: json['isActive']);
  }

  static List<TActivity> fromJsonArray(List<dynamic> jsonArray) {
    return jsonArray.map((json) => TActivityModel.fromJson(json)).toList();
  }

  factory TActivityModel.fromId(String transActivityId) {
    return TActivityModel(transActivityId: transActivityId);
  }

  Map<String, dynamic> toJson() {
    return {
      'transActivityId': id,
      'mactivity': (mActivity as MActivityModel).toJson(),
      'isActive': isActive
    };
  }

  Map<String, dynamic> toFirestore(Firestore firestore) {
    //debugger();
    return {
      'mActivity': firestore.document("/mActivity/${mActivity.id}"),
      'isActive': isActive,
      'tMood': firestore.document("/tMood/${tMood.id}")
    };
  }

  factory TActivityModel.fromFirestore(DocumentSnapshot doc) {
    //debugger();
    if (doc == null) {
      return null;
    }
    return TActivityModel(
        transActivityId: doc['transActivityId'],
        isActive: doc['isActive'],
        mActivityModel: MActivityModel.fromId(
            (doc['mActivity'] as DocumentReference).documentID),
        tMoodModel:
            TMoodModel.fromId((doc['tMood'] as DocumentReference).documentID));
  }

  factory TActivityModel.initial() {
    return TActivityModel(
        transActivityId: '',
        mActivityModel: MActivityModel.initial(),
        isActive: true,
        tMoodModel: TMoodModel.initial());
  }
}
