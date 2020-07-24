import 'package:intl/intl.dart';
import 'package:mood_manager/core/constants.dart/app_constants.dart';

import 'package:mood_manager/features/mood_manager/data/models/m_activity_model.dart';
import 'package:mood_manager/features/mood_manager/data/models/t_activity_model.dart';
import 'package:mood_manager/features/mood_manager/data/models/m_mood_model.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_mood.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class TMoodModel extends TMood {
  TMoodModel(
      {int transMoodId,
      @required String moodName,
      @required String moodCode,
      String note,
      @required DateTime logDateTime,
      List<TActivityModel> tActivityModelList,
      MMoodModel mMoodModel,
      bool isActive = true})
      : super(
            transMoodId: transMoodId,
            moodName: moodName,
            moodCode: moodCode,
            note: note,
            logDateTime: logDateTime,
            tActivityList: tActivityModelList,
            mMood: mMoodModel,
            isActive: isActive);

  factory TMoodModel.fromMood(
      TMoodModel tMood, List<MActivityModel> mActivityList, String note) {
    return TMoodModel(
        logDateTime: tMood.logDateTime,
        moodCode: tMood.moodCode,
        moodName: tMood.moodName,
        tActivityModelList: mActivityList
            .map((mActivity) => TActivityModel(
                activityCode: mActivity.code,
                activityName: mActivity.name,
                mActivityModel: mActivity))
            .toList(),
        note: note,
        mMoodModel: tMood.mMood);
  }

  factory TMoodModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return TMoodModel(
        transMoodId: json['transMoodId'],
        moodName: json['moodName'],
        moodCode: json['moodCode'],
        note: json['note'] == null ? '' : json['note'],
        tActivityModelList:
            TActivityModel.fromJsonArray(json['tactivityList'] as List),
        logDateTime:
            DateFormat("yyyy-MM-dd@HH:mm:ss").parse(json['logDateTime']),
        mMoodModel: MMoodModel.fromJson(json['mmood']));
  }

  static List<TMoodModel> fromJsonArray(List<dynamic> jsonArray) {
    return jsonArray.map((json) => TMoodModel.fromJson(json)).toList();
  }

  static Map<DateTime, List<TMoodModel>> subListMapByDate(
    List<TMoodModel> tMoodList,
  ) {
    return Map.fromEntries(tMoodList
        .map((tMood) => DateFormat(AppConstants.HEADER_DATE_FORMAT)
            .format(tMood.logDateTime))
        .toList()
        .toSet()
        .toList()
        .map((dateStr) => MapEntry<DateTime, List<TMoodModel>>(
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
      'moodName': moodName,
      'moodCode': moodCode,
      'note': note,
      'logDateTime': DateFormat("yyyy-MM-dd@HH:mm:ss").format(logDateTime),
      'tactivityList': tActivityListMap,
      'mmood': (mMood as MMoodModel).toJson(),
      'isActive': isActive
    };
  }
}
