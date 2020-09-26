import 'package:flutter/material.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/base_m.dart';

class Gender extends BaseM {
  final String altName;
  Gender({
    @required String id,
    @required String name,
    @required String code,
    @required bool isActive,
    @required this.altName,
  }) : super(
            id: id,
            name: name,
            code: code,
            isActive: isActive,
            className: 'gender');
}
