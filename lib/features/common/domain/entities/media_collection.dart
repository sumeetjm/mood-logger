import 'package:mood_manager/features/common/data/models/media_collection_parse.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'media_collection.g.dart';

@HiveType(typeId: 5)
class MediaCollection extends Base {
  @HiveField(3)
  final String mediaType;
  @HiveField(4)
  final String name;
  @HiveField(5)
  final String code;
  @HiveField(6)
  final String module;
  @HiveField(7)
  int imageCount;
  @HiveField(8)
  int videoCount;
  @HiveField(9)
  int mediaCount;
  @HiveField(10)
  Color averageMediaColor;
  ParseUser user;

  MediaCollection({
    String id,
    this.name,
    this.code,
    this.module,
    this.mediaType,
    this.imageCount = 0,
    this.videoCount = 0,
    this.mediaCount = 0,
    bool isActive = true,
    this.averageMediaColor,
    this.user,
  }) : super(
          id: id,
          isActive: isActive,
          className: 'mediaCollection',
        );

  @override
  List<Object> get props =>
      [...super.props, mediaType, name, code, module, averageMediaColor];
}
