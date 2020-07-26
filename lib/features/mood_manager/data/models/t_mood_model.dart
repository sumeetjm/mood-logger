import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mood_manager/core/constants.dart/app_constants.dart';

import 'package:mood_manager/features/mood_manager/data/models/t_activity_model.dart';
import 'package:mood_manager/features/mood_manager/data/models/m_mood_model.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_activity.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_activity.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_mood.dart';

class TMoodModel extends TMood {
  TMoodModel(
      {String transMoodId,
      String note,
      DateTime logDateTime,
      List<TActivity> tActivityModelList,
      MMoodModel mMoodModel,
      bool isActive = true})
      : super(
            transMoodId: transMoodId,
            note: note,
            logDateTime: logDateTime,
            tActivityList: tActivityModelList,
            mMood: mMoodModel,
            isActive: isActive);

  factory TMoodModel.fromMood(
      TMoodModel tMood, List<MActivity> mActivityList, String note) {
    return TMoodModel(
        logDateTime: tMood.logDateTime,
        tActivityModelList: mActivityList
            .map((mActivity) => TActivityModel(mActivityModel: mActivity))
            .toList(),
        note: note,
        mMoodModel: tMood.mMood);
  }

  factory TMoodModel.fromId(String transMoodId) {
    return TMoodModel(transMoodId: transMoodId);
  }

  factory TMoodModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return TMoodModel(
        transMoodId: json['transMoodId'],
        note: json['note'] == null ? '' : json['note'],
        tActivityModelList:
            TActivityModel.fromJsonArray(json['tactivityList'] as List),
        logDateTime:
            DateFormat("yyyy-MM-dd@HH:mm:ss").parse(json['logDateTime']),
        mMoodModel: MMoodModel.fromJson(json['mmood']));
  }

  factory TMoodModel.fromFirestore(DocumentSnapshot doc) {
    if (doc == null) {
      return null;
    }
    return TMoodModel(
        transMoodId: doc.documentID,
        note: doc['note'] ?? '',
        logDateTime: DateTime.fromMillisecondsSinceEpoch(
            (doc['logDateTime'] as Timestamp).millisecondsSinceEpoch),
        isActive: doc['isActive'],
        mMoodModel:
            MMoodModel.fromId((doc['mMood'] as DocumentReference).documentID));
  }

  static List<TMoodModel> fromJsonArray(List<dynamic> jsonArray) {
    return jsonArray.map((json) => TMoodModel.fromJson(json)).toList();
  }

  static Map<DateTime, List<TMood>> subListMapByDate(
    List<TMood> tMoodList,
  ) {
    return Map.fromEntries(tMoodList
        .map((tMood) => DateFormat(AppConstants.HEADER_DATE_FORMAT)
            .format(tMood.logDateTime))
        .toList()
        .toSet()
        .toList()
        .map((dateStr) => MapEntry<DateTime, List<TMood>>(
            DateFormat(AppConstants.HEADER_DATE_FORMAT).parse(dateStr),
            tMoodList
                .where((element) =>
                    DateFormat(AppConstants.HEADER_DATE_FORMAT)
                        .format(element.logDateTime) ==
                    dateStr)
                .toList())));
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> tActivityListMap = tActivityList
        .map((activity) => (activity as TActivityModel).toJson())
        .toList();
    return {
      'transMoodId': transMoodId,
      'note': note,
      'logDateTime': DateFormat("yyyy-MM-dd@HH:mm:ss").format(logDateTime),
      'tactivityList': tActivityListMap,
      'mmood': (mMood as MMoodModel).toJson(),
      'isActive': isActive
    };
  }

  Map<String, dynamic> toFirestore(Firestore firestore) {
    return {
      'note': note,
      'logDateTime': logDateTime,
      'mMood': firestore.document("/mMood/${mMood.id}"),
      'isActive': isActive
    };
  }
}
