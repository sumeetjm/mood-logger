import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mood_manager/core/util/hex_color.dart';
import 'package:mood_manager/features/common/data/models/media_parse.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player/cached_video_player.dart';
import 'package:image/image.dart' as img;
import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:hive/hive.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

part 'media.g.dart';

@HiveType(typeId: 4)
class Media extends Base {
  @HiveField(3)
  ParseFile file;
  @HiveField(4)
  ParseFile thumbnail;
  @HiveField(5)
  final String mediaType;
  @HiveField(6)
  Color dominantColor;

  Media({
    String id,
    @required this.file,
    @required this.thumbnail,
    @required this.mediaType,
    @required this.dominantColor,
    bool isActive = true,
  }) : super(
          id: id,
          isActive: isActive,
          className: 'media',
        );

  @override
  List<Object> get props => [...super.props, tag(), mediaType];

  ImageProvider get thumbnailProvider {
    if (thumbnail.url != null) {
      return CachedNetworkImageProvider(thumbnail.url);
    } else if (thumbnail?.file != null) {
      return FileImage(thumbnail.file);
    } else {
      return null;
    }
  }

  ImageProvider get imageProvider {
    if (file?.url != null) {
      return CachedNetworkImageProvider(file.url);
    } else if (file?.file != null) {
      return FileImage(file.file);
    } else {
      return null;
    }
  }

  Widget get image {
    if (file?.url != null) {
      return CachedNetworkImage(
        imageUrl: file.url,
        placeholder: (context, url) =>
            new Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => new Icon(Icons.error),
      );
    } else if (file?.file != null) {
      return Image.file(file.file);
    } else {
      return null;
    }
  }

  Widget get thumbnailImage {
    if (thumbnail?.url != null) {
      return CachedNetworkImage(
        imageUrl: thumbnail.url,
        placeholder: (context, url) =>
            new Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => new Icon(Icons.error),
      );
    } else if (thumbnail?.file != null) {
      return Image.file(thumbnail.file);
    } else {
      return null;
    }
  }

  Future<File> mediaFile() async {
    return (await file.download()).file;
  }

  Future<File> thumbnailFile() async {
    return (await thumbnail.download()).file;
  }

  CachedVideoPlayerController get videoController {
    if (file?.url != null) {
      return CachedVideoPlayerController.network(file.url);
    } else if (file?.file != null) {
      return CachedVideoPlayerController.file(file.file);
    } else {
      return null;
    }
  }

  String tag({suffix = ""}) => (file?.url ?? file?.file?.path ?? '') + suffix;

  Future<void> delete() async {
    await file?.file?.delete();
    await thumbnail?.file?.delete();
    /*if (file.saved) {
      await file.delete();
    }
    if (thumbnail.saved) {
      await thumbnail.delete();
    }*/
  }

  setDominantColor() async {
    dominantColor =
        (await PaletteGenerator.fromImageProvider(FileImage(thumbnail.file)))
            .dominantColor
            .color;
  }

  setThumbnail(final String thumbnailDir, final String name) async {
    File thumbnailFile = File(thumbnailDir + "/" + name + ".jpg");
    if (mediaType == 'PHOTO') {
      thumbnailFile.writeAsBytesSync(img.encodeJpg(img.copyResize(
          img.decodeImage(file.file.readAsBytesSync()),
          width: 200)));
    } else {
      try {
        await VideoThumbnail.thumbnailFile(
          video: file.file.path,
          thumbnailPath: thumbnailFile.path,
          imageFormat: ImageFormat.JPEG,
          maxHeight:
              200, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
          quality: 50,
        );
      } catch (e) {
        thumbnailFile = (await thumbnail.download()).file;
      }
    }
    thumbnail = ParseFile(thumbnailFile);
  }
}
