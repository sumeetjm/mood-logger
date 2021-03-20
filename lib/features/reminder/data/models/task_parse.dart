import 'package:flutter/cupertino.dart';
import 'package:mood_manager/core/util/hex_color.dart';
import 'package:mood_manager/features/common/data/models/parse_mixin.dart';
import 'package:mood_manager/features/metadata/data/models/m_activity_parse.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity.dart';
import 'package:mood_manager/features/reminder/domain/entities/task.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class TaskParse extends Task with ParseMixin {
  TaskParse({
    String id,
    String note,
    List<MActivity> mActivityList,
    bool isActive = true,
    DateTime taskDateTime,
    ParseUser user,
    Color color,
  }) : super(
          id: id,
          note: note,
          mActivityList: mActivityList,
          isActive: isActive,
          user: user,
          color: color,
          taskDateTime: taskDateTime,
        );

  @override
  Base get get => this;

  @override
  Map<String, dynamic> get map => {
        'objectId': id,
        'note': note,
        'mActivity': mActivityList,
        'isActive': isActive,
        'taskDateTime': taskDateTime?.toUtc(),
        'user': user,
        'hexColor': color?.toHex(),
      };

  static TaskParse from(ParseObject parseObject,
      {TaskParse cacheData, List<String> cacheKeys = const []}) {
    if (parseObject == null) {
      return null;
    }
    final parseOptions = {
      'cacheData': cacheData,
      'cacheKeys': cacheKeys ?? [],
      'data': parseObject,
    };
    return TaskParse(
      id: ParseMixin.value('objectId', parseOptions),
      note: ParseMixin.value('note', parseOptions),
      taskDateTime: ParseMixin.value('taskDateTime', parseOptions)?.toLocal(),
      mActivityList: List<MActivity>.from(ParseMixin.value(
          'mActivity', parseOptions,
          transform: MActivityParse.from)),
      isActive: ParseMixin.value('isActive', parseOptions),
      user: ParseMixin.value('user', parseOptions),
      color: ParseMixin.value('hexColor', parseOptions,
          transform: HexColor.fromHex),
    );
  }
}
