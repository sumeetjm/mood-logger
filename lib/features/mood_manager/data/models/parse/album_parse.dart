import 'package:flutter/material.dart';
import 'package:mood_manager/features/mood_manager/data/models/parse/album_type_parse.dart';
import 'package:mood_manager/features/mood_manager/data/models/parse/base_m_parse_mixin.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/album.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/album_type.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class AlbumParse extends Album with BaseMParseMixin {
  AlbumParse({
    AlbumType albumType,
    String id,
    @required String name,
    bool isActive,
    Map<String, dynamic> userProfilePointer,
  }) : super(
          id: id,
          name: name,
          isActive: isActive,
          albumType: albumType,
          userProfilePointer: userProfilePointer,
        );

  factory AlbumParse.fromParseObject(ParseObject parseObject) {
    return AlbumParse(
      name: parseObject.get('name'),
      id: parseObject.get('objectId'),
      isActive: parseObject.get('isActive'),
      userProfilePointer:
          (parseObject.get('userDtl') as ParseObject).toPointer(),
      albumType: AlbumTypeParse.fromParseObject(parseObject.get('albumType')),
    );
  }

  ParseObject toParseObject() {
    final parseObject = baseParseObject(this);
    parseObject.set('albumType', (albumType as AlbumTypeParse).toParseObject());
    parseObject.set('userDtl', userProfilePointer);
    return parseObject;
  }
}
