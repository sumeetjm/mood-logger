import 'package:flutter/material.dart';
import 'package:mood_manager/core/util/hex_color.dart';
import 'package:mood_manager/features/common/data/models/parse_mixin.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/memory/domain/entities/memory_collection.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

// ignore: must_be_immutable
class MemoryCollectionParse extends MemoryCollection with ParseMixin {
  MemoryCollectionParse({
    String id,
    String name,
    String code,
    bool isActive = true,
    Color averageMemoryMoodColor,
    int memoryCount = 0,
  }) : super(
          id: id,
          name: name,
          code: code ?? name,
          isActive: isActive,
          averageMemoryMoodColor: averageMemoryMoodColor,
          memoryCount: memoryCount,
        );

  @override
  Base get get => this;

  @override
  Map<String, dynamic> get map => {
        'objectId': id,
        'name': name,
        'code': code,
        'isActive': isActive,
        'averageMemoryMoodHexColor': averageMemoryMoodColor.toHex(),
        'memoryCount': memoryCount,
      };

  static MemoryCollectionParse from(ParseObject parseObject,
      {MemoryCollectionParse cacheData, List<String> cacheKeys = const []}) {
    if (parseObject == null) {
      return null;
    }
    final parseOptions = {
      'cacheData': cacheData,
      'cacheKeys': cacheKeys ?? [],
      'data': parseObject,
    };
    return MemoryCollectionParse(
      id: ParseMixin.value('objectId', parseOptions),
      name: ParseMixin.value('name', parseOptions),
      code: ParseMixin.value('code', parseOptions),
      isActive: ParseMixin.value('isActive', parseOptions),
      averageMemoryMoodColor: ParseMixin.value(
          'averageMemoryMoodHexColor', parseOptions,
          transform: HexColor.fromHex),
      memoryCount: ParseMixin.value('memoryCount', parseOptions),
    );
  }
}
