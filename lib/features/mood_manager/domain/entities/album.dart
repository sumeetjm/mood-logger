import 'package:flutter/material.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/album_type.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/base_m.dart';

class Album extends BaseM {
  final AlbumType albumType;
  final Map<String, dynamic> userProfilePointer;

  Album({
    @required this.albumType,
    String id,
    @required String name,
    bool isActive,
    @required this.userProfilePointer,
  }) : super(
          id: id,
          name: name,
          code: name,
          isActive: isActive,
          className: 'album',
        );
}
