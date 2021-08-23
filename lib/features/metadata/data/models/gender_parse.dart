import 'package:flutter/material.dart';
import 'package:mood_manager/features/common/data/models/parse_mixin.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/metadata/domain/entities/gender.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class GenderParse extends Gender with ParseMixin {
  GenderParse({
    String id,
    @required String name,
    String code,
    String altName,
    String iconKey,
    bool isActive = true,
  }) : super(
          id: id,
          name: name,
          code: code,
          isActive: isActive,
          altName: altName,
          iconKey: iconKey,
        );

  static GenderParse from(ParseObject parseObject,
      {GenderParse cacheData, List<String> cacheKeys = const []}) {
    if (parseObject == null) {
      return null;
    }
    final parseOptions = {
      'cacheData': cacheData,
      'cacheKeys': cacheKeys ?? [],
      'data': parseObject,
    };
    return GenderParse(
      id: ParseMixin.value('objectId', parseOptions),
      name: ParseMixin.value('name', parseOptions),
      code: ParseMixin.value('code', parseOptions),
      altName: ParseMixin.value('altName', parseOptions),
      iconKey: ParseMixin.value('iconKey', parseOptions),
      isActive: ParseMixin.value('isActive', parseOptions),
    );
  }

  @override
  Base get get => this;

  @override
  Map<String, dynamic> get map => {
        'objectId': id,
        'name': name,
        'code': code,
        'altName': altName,
        'iconKey': iconKey,
        'isActive': isActive
      };
}
