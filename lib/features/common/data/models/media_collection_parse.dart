import 'package:mood_manager/features/common/data/models/parse_mixin.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:flutter/material.dart';
import 'package:mood_manager/core/util/hex_color.dart';

class MediaCollectionParse extends MediaCollection with ParseMixin {
  @override
  Base get get => this;

  MediaCollectionParse(
      {String id,
      bool isActive = true,
      String code,
      String name,
      String mediaType,
      String module,
      int imageCount = 0,
      int videoCount = 0,
      int mediaCount = 0,
      ParseUser user,
      Color averageMediaColor})
      : super(
          id: id,
          isActive: isActive,
          code: code,
          name: name ?? code,
          mediaType: mediaType,
          module: module,
          videoCount: videoCount,
          imageCount: imageCount,
          mediaCount: mediaCount,
          averageMediaColor: averageMediaColor,
          user: user,
        );

  @override
  Map<String, dynamic> get map => {
        'objectId': id,
        'name': name,
        'code': code,
        'mediaType': mediaType,
        'module': module,
        'isActive': isActive,
        'user': user,
        'averageMediaHexColor': averageMediaColor?.toHex()
      };

  static MediaCollectionParse from(ParseObject parseObject,
      {MediaCollectionParse cacheData, List<String> cacheKeys = const []}) {
    if (parseObject == null) {
      return null;
    }
    final parseOptions = {
      'cacheData': cacheData,
      'cacheKeys': cacheKeys ?? [],
      'data': parseObject,
    };
    return MediaCollectionParse(
      id: ParseMixin.value('objectId', parseOptions),
      name: ParseMixin.value('name', parseOptions),
      code: ParseMixin.value('code', parseOptions),
      mediaType: ParseMixin.value('mediaType', parseOptions),
      module: ParseMixin.value('module', parseOptions),
      imageCount: ParseMixin.value('imageCount', parseOptions),
      videoCount: ParseMixin.value('videoCount', parseOptions),
      mediaCount: ParseMixin.value('mediaCount', parseOptions),
      isActive: ParseMixin.value('isActive', parseOptions),
      user: ParseMixin.value('user', parseOptions),
      averageMediaColor: ParseMixin.value('averageMediaHexColor', parseOptions,
          transform: HexColor.fromHex),
    );
  }
}
