import 'package:flutter/material.dart';
import 'package:mood_manager/features/mood_manager/data/models/parse/album_parse.dart';
import 'package:mood_manager/features/mood_manager/data/models/parse/base_m_parse_mixin.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/album.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/photo.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class PhotoParse extends Photo with BaseMParseMixin {
  PhotoParse({
    String id,
    @required ParseFile image,
    bool isActive = true,
    @required Album album,
  }) : super(
          id: id,
          image: image,
          isActive: isActive,
          album: album,
        );

  static PhotoParse fromParseObject(ParseObject parseObject) {
    if (parseObject == null) {
      return null;
    }
    return PhotoParse(
      id: parseObject.get('objectId'),
      image: parseObject.get('image'),
      isActive: parseObject.get('isActive'),
      album: AlbumParse.fromParseObject(parseObject.get('album')),
    );
  }

  ParseObject toParseObject() {
    ParseObject parseObject = baseParseObject(this);
    parseObject.set('image', image);
    parseObject.set('album', (album as AlbumParse).toParseObject());
    return parseObject;
  }
}
