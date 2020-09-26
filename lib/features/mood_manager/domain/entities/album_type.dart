import 'package:flutter/material.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/base_m.dart';

class AlbumType extends BaseM {
  AlbumType({
    String id,
    @required String name,
    @required String code,
    bool isActive = true,
  }) : super(
          id: id,
          name: name,
          code: code,
          isActive: isActive,
          className: 'albumType',
        );
}
