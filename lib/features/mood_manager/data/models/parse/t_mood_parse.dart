import 'package:intl/intl.dart';
import 'package:mood_manager/core/constants/app_constants.dart';
import 'package:mood_manager/features/mood_manager/data/models/parse/base_parse_mixin.dart';

import 'package:mood_manager/features/mood_manager/data/models/parse/m_mood_parse.dart';
import 'package:mood_manager/features/mood_manager/data/models/parse/t_activity_parse.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/base.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_activity.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_mood.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_activity.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_mood.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class TMoodParse extends TMood with ParseMixin {
  TMoodParse(
      {String transMoodId,
      String note,
      DateTime logDateTime,
      List<TActivity> tActivityList,
      MMood mMood,
      bool isActive = true})
      : super(
          id: transMoodId,
          note: note,
          logDateTime: logDateTime,
          mMood: mMood,
          tActivityList: tActivityList,
          isActive: isActive,
        );

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

  factory TMoodParse.initial() {
    return TMoodParse(
        transMoodId: '',
        isActive: true,
        logDateTime: DateTime.now(),
        mMood: MMoodParse.initial(),
        tActivityList: [],
        note: '');
  }

  factory TMoodParse.fromMood(
      TMood tMood, List<MActivity> mActivityList, String note) {
    return TMoodParse(
        logDateTime: tMood.logDateTime,
        tActivityList: mActivityList
            .map((mActivity) => TActivityParse(mActivity: mActivity))
            .toList(),
        note: note,
        mMood: tMood.mMood);
  }

  static TMoodParse from(ParseObject parseObject,
      {TMoodParse cacheData, List<String> cacheKeys = const []}) {
    if (parseObject == null) {
      return null;
    }
    final parseOptions = {
      'cacheData': cacheData,
      'cacheKeys': cacheKeys ?? [],
      'data': parseObject,
    };
    return TMoodParse(
      transMoodId: ParseMixin.value('objectId', parseOptions),
      note: ParseMixin.value('note', parseOptions),
      tActivityList: List<TActivity>.from(ParseMixin.value(
          'tActivity', parseOptions,
          transform: TActivityParse.from)),
      logDateTime: ParseMixin.value('logDateTime', parseOptions),
      mMood: ParseMixin.value('logDateTime', parseOptions,
          transform: MMoodParse.from),
    );
  }

  @override
  Base get get => this;

  @override
  Map<String, dynamic> get map => {
        'objectId': id,
        'logDateTime': logDateTime?.toUtc(),
        'note': note,
        'mMood': mMood,
      };
}
