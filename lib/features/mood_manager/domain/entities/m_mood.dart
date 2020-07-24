import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/base_m.dart';

class MMood extends BaseM {
  final Color color;

  MMood({
    int moodId,
    String moodName,
    String moodCode,
    bool isActive,
    @required this.color,
  }) : super(id: moodId, name: moodName, code: moodCode, isActive: isActive);

  @override
  List<Object> get props => [id, name, code, color];
}
