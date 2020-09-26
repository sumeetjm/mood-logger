import 'package:flutter/material.dart';
import 'package:mood_manager/features/mood_manager/data/models/parse/base_m_parse_mixin.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/album_type.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class AlbumTypeParse extends AlbumType with BaseMParseMixin {
  AlbumTypeParse({
    String id,
    @required String name,
    @required String code,
    bool isActive = true,
  }) : super(
          id: id,
          name: name,
          code: code,
          isActive: isActive,
        );

  factory AlbumTypeParse.fromParseObject(ParseObject parseObject) {
    return AlbumTypeParse(
      id: parseObject.get('objectId'),
      code: parseObject.get('code'),
      name: parseObject.get('name'),
      isActive: parseObject.get('isActive'),
    );
  }

  ParseObject toParseObject() {
    final parseObject = baseParseObject(this);
    return parseObject;
  }
}
