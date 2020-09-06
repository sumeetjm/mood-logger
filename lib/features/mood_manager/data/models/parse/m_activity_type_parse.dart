import 'dart:developer';

import 'package:mood_manager/features/mood_manager/data/models/parse/m_activity_parse.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_activity.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_activity_type.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class MActivityTypeParse extends MActivityType {
  MActivityTypeParse({
    String activityTypeId,
    String activityTypeName,
    String activityTypeCode,
    bool isActive = true,
    List<MActivity> mActivityList,
  }) : super(
            activityTypeId: activityTypeId,
            activityTypeName: activityTypeCode,
            activityTypeCode: activityTypeCode,
            mActivityList: mActivityList,
            isActive: isActive);

  factory MActivityTypeParse.fromId(String activityTypeId) {
    return MActivityTypeParse(activityTypeId: activityTypeId);
  }

  factory MActivityTypeParse.initial() {
    return MActivityTypeParse(
        activityTypeId: '',
        activityTypeName: '',
        activityTypeCode: '',
        mActivityList: [],
        isActive: true);
  }

  factory MActivityTypeParse.fromParseObject(ParseObject parseObject) {
    if (parseObject == null) {
      return null;
    }
    return MActivityTypeParse(
        activityTypeId: parseObject.get('objectId'),
        activityTypeName: parseObject.get('name'),
        activityTypeCode: parseObject.get('code'),
        isActive: parseObject.get('isActive'),
        mActivityList: MActivityParse.fromParseArray(
            parseObject.get('mActivity') as List));
  }

  ParseObject toParseObject() {
    ParseObject parseObject = ParseObject('mActivityType');
    parseObject.set('objectId', id);
    parseObject.set('name', name);
    parseObject.set('code', code);
    parseObject.set('isActive', isActive);
    parseObject.set('mActivity',
        mActivityList.map((e) => (e as MActivityParse).toParsePointer()));
    return parseObject;
  }

  static List<MActivityTypeParse> fromParseArray(List<dynamic> parseArray) {
    return (parseArray ?? [])
        .where((element) => (element as ParseObject).get('isActive'))
        .map((parseObject) => MActivityTypeParse.fromParseObject(parseObject))
        .toList();
  }

  Map<String, dynamic> toParsePointer() {
    return {'__type': 'Pointer', 'className': 'mActivityType', 'objectId': id};
  }
}
