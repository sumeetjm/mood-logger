import 'package:flutter/cupertino.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class Task extends Base {
  final String note;
  final List<MActivity> mActivityList;
  final DateTime taskDateTime;
  ParseUser user;
  Color color;

  Task({
    String id,
    this.note,
    this.mActivityList,
    bool isActive = true,
    this.taskDateTime,
    this.user,
    this.color,
  }) : super(
          id: id,
          isActive: isActive,
          className: 'task',
        );

  @override
  List<Object> get props => [
        note,
        mActivityList,
        taskDateTime,
        color,
        user,
        ...super.props,
      ];
}
