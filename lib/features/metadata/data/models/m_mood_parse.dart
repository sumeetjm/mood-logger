import 'package:dartz/dartz.dart';
import 'package:mood_manager/core/util/hex_color.dart';
import 'package:mood_manager/features/common/data/models/parse_mixin.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_mood.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class MMoodParse extends MMood with ParseMixin {
  MMoodParse({
    String moodId,
    String moodName,
    String moodCode,
    Color color,
    List<MMood> mMoodList,
    bool isActive = true,
  }) : super(
          moodId: moodId,
          moodName: moodName,
          moodCode: moodCode,
          color: color,
          mMoodList: mMoodList,
          isActive: isActive,
        );

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

  static MMoodParse from(ParseObject parseObject,
      {MMoodParse cacheData, List<String> cacheKeys = const []}) {
    if (parseObject == null) {
      return null;
    }
    final parseOptions = {
      'cacheData': cacheData,
      'cacheKeys': cacheKeys ?? [],
      'data': parseObject,
    };
    return MMoodParse(
      moodId: ParseMixin.value('objectId', parseOptions),
      moodName: ParseMixin.value('name', parseOptions),
      moodCode: ParseMixin.value('code', parseOptions),
      isActive: ParseMixin.value('isActive', parseOptions),
      color: ParseMixin.value('hexColor', parseOptions,
          transform: HexColor.fromHex),
      mMoodList: List<MMood>.from(ParseMixin.value('subMood', parseOptions,
          transform: MMoodParse.from)),
    );
  }

  @override
  Base get get => this;

  @override
  Map<String, dynamic> get map => {
        'objectId': id,
        'name': moodName,
        'code': moodCode,
        'hexColor': color?.toHex(),
        'subMood': mMoodList,
        'isActive': isActive
      };
}
