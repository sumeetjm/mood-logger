import 'package:flutter/material.dart';
import 'package:mood_manager/features/common/data/models/parse_mixin.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/common/domain/entities/media.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class MediaParse extends Media with ParseMixin {
  MediaParse({
    String id,
    @required ParseFile file,
    bool isActive = true,
  }) : super(
          id: id,
          file: file,
          isActive: isActive,
        );

  static MediaParse from(ParseObject parseObject,
      {MediaParse cacheData, List<String> cacheKeys = const []}) {
    if (parseObject == null) {
      return null;
    }
    final parseOptions = {
      'cacheData': cacheData,
      'cacheKeys': cacheKeys ?? [],
      'data': parseObject,
    };
    return MediaParse(
      id: ParseMixin.value('objectId', parseOptions),
      file: ParseMixin.value('file', parseOptions),
      isActive: ParseMixin.value('isActive', parseOptions),
    );
  }

  @override
  Base get get => this;

  @override
  Map<String, dynamic> get map => {
        'objectId': id,
        'file': file,
        'isActive': isActive,
      };
}
