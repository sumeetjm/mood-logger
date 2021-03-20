import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player/cached_video_player.dart';

import 'package:mood_manager/features/common/domain/entities/base.dart';

class Media extends Base {
  ParseFile file;
  ParseFile thumbnail;
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

  Widget get imageProvider {
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
