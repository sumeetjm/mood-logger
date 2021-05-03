import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mood_manager/features/common/data/models/media_parse.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player/cached_video_player.dart';

import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:hive/hive.dart';

part 'media.g.dart';

@HiveType(typeId: 4)
class Media extends Base {
  @HiveField(3)
  ParseFile file;
  @HiveField(4)
  ParseFile thumbnail;
  @HiveField(5)
  final String mediaType;

  Media({
    String id,
    @required this.file,
    @required this.thumbnail,
    @required this.mediaType,
    bool isActive = true,
  }) : super(
          id: id,
          isActive: isActive,
          className: 'media',
        );

  @override
  List<Object> get props =>
      [...super.props, file.url, thumbnail.url, mediaType];

  ImageProvider get thumbnailProvider {
    if (thumbnail.url != null) {
      return CachedNetworkImageProvider(thumbnail.url);
    } else {
      return FileImage(thumbnail.file);
    }
  }

  ImageProvider get imageProvider {
    if (file?.url != null) {
      return CachedNetworkImageProvider(file.url);
    } else {
      return FileImage(file.file);
    }
  }

  Widget get image {
    if (file.url != null) {
      return CachedNetworkImage(
        imageUrl: file.url,
        placeholder: (context, url) =>
            new Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => new Icon(Icons.error),
      );
    } else {
      return Image.file(file.file);
    }
  }

  CachedVideoPlayerController get videoController {
    if (file.url != null) {
      return CachedVideoPlayerController.network(file.url);
    } else {
      return CachedVideoPlayerController.file(file.file);
    }
  }

  String get tag =>
      (file.url ?? file.file.path) +
      (file.objectId ?? file.hashCode.toString());
}
