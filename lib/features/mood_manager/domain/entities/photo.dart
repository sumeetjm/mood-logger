import 'package:flutter/material.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/album.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

import 'package:mood_manager/features/mood_manager/domain/entities/base_m.dart';

class Photo extends BaseM {
  final ParseFile image;
  final Album album;

  Photo({
    String id,
    @required this.image,
    bool isActive = true,
    @required this.album,
  }) : super(
          id: id,
          name: image?.name,
          code: image?.name,
          isActive: isActive,
          className: 'photo',
        );
}
