import 'package:flutter/cupertino.dart';
import 'package:mood_manager/core/util/hex_color.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity.dart';
import 'package:mood_manager/features/reminder/data/models/task_parse.dart';
import 'package:mood_manager/features/reminder/domain/entities/task_repeat.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 11)
class Task extends Base {
  @HiveField(3)
  final String title;
  @HiveField(4)
  final String note;
  @HiveField(5)
  final List<MActivity> mActivityList;
  @HiveField(6)
  final DateTime taskDateTime;
  @HiveField(7)
  final DateTime notificationDateTime;
  ParseUser user;
  @HiveField(8)
  Color color;
  @HiveField(9)
  final TaskRepeat taskRepeat;
  @HiveField(10)
  final Map<DateTime, Memory> memoryMapByDate;

  Task({
    String id,
    this.title,
    this.note,
    this.mActivityList,
    bool isActive = true,
    this.taskDateTime,
    this.notificationDateTime,
    this.user,
    this.color,
    this.taskRepeat,
    this.memoryMapByDate,
  }) : super(
          id: id,
          isActive: isActive,
          className: 'task',
        );

  @override
  List<Object> get props => [
        title,
        note,
        mActivityList,
        taskDateTime,
        notificationDateTime,
        color,
        user,
        taskRepeat,
        memoryMapByDate,
        ...super.props,
      ];
}
