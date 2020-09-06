import 'dart:developer';

import 'package:mood_manager/core/util/hex_color.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_mood.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class MMoodParse extends MMood {
  MMoodParse(
      {String moodId,
      String moodName,
      String moodCode,
      Color color,
      List<MMood> mMoodList,
      bool isActive = true})
      : super(
            moodId: moodId,
            moodName: moodName,
            moodCode: moodCode,
            color: color,
            mMoodList: mMoodList,
            isActive: isActive);

  factory MMoodParse.fromId(String moodId) {
    return MMoodParse(moodId: moodId);
  }

  factory MMoodParse.initial() {
    return MMoodParse(
        color: Colors.white,
        isActive: true,
        moodCode: '',
        moodId: '',
        moodName: '',
        mMoodList: []);
  }

  factory MMoodParse.fromParseObject(ParseObject parseObject) {
    if (parseObject == null) {
      return null;
    }
    return MMoodParse(
        moodId: parseObject.get('objectId'),
        moodName: parseObject.get('name'),
        moodCode: parseObject.get('code'),
        isActive: parseObject.get('isActive'),
        color: HexColor.fromHex(parseObject.get('hexColor')),
        mMoodList: MMoodParse.fromParseArray(parseObject.get('subMood')));
  }

  static List<MMoodParse> fromParseArray(List<dynamic> parseArray) {
    return (parseArray ?? [])
        .where((element) => (element as ParseObject).get('isActive'))
        .map((parseObject) => MMoodParse.fromParseObject(parseObject))
        .toList();
  }

  ParseObject toParseObject() {
    ParseObject parseObject = ParseObject('mMood');
    parseObject.set('objectId', id);
    parseObject.set('name', name);
    parseObject.set('code', code);
    parseObject.set('hexColor', color.toHex());
    parseObject.set('isActive', isActive);
    parseObject.set(
        'subMood',
        mMoodList
            .map((mMood) => (mMood as MMoodParse).toParseObject())
            .toList());
    return parseObject;
  }

  Map<String, dynamic> toParsePointer() {
    return {'__type': 'Pointer', 'className': 'mMood', 'objectId': id};
  }
}
