import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

import 'package:mood_manager/features/common/domain/entities/base.dart';

class Media extends Base {
  final ParseFile file;

  Media({
    String id,
    @required this.file,
    bool isActive = true,
  }) : super(
          id: id,
          isActive: isActive,
          className: 'media',
        );
  @override
  // TODO: implement props
  List<Object> get props => [...super.props, file.url];
}