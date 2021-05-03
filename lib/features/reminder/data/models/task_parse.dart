import 'package:calendar_strip/date-utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:mood_manager/core/constants/app_constants.dart';
import 'package:mood_manager/core/util/date_util.dart';
import 'package:mood_manager/core/util/hex_color.dart';
import 'package:mood_manager/features/common/data/models/parse_mixin.dart';
import 'package:mood_manager/features/memory/data/models/memory_parse.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:mood_manager/features/metadata/data/models/m_activity_parse.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity.dart';
import 'package:mood_manager/features/reminder/data/models/task_repeat_parse.dart';
import 'package:mood_manager/features/reminder/domain/entities/task.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:mood_manager/features/reminder/domain/entities/task_repeat.dart';

class TaskParse extends Task with ParseMixin {
  TaskParse({
    String id,
    String note,
    String title,
    List<MActivity> mActivityList,
    bool isActive = true,
    DateTime taskDateTime,
    DateTime notificationDateTime,
    ParseUser user,
    Color color,
    TaskRepeat taskRepeat,
    Map<DateTime, Memory> memoryMapByDate = const {},
  }) : super(
          id: id,
          note: note,
          title: title,
          mActivityList: mActivityList,
          isActive: isActive,
          user: user,
          color: color,
          taskDateTime: taskDateTime,
          notificationDateTime: notificationDateTime,
          taskRepeat: taskRepeat,
          memoryMapByDate: memoryMapByDate,
        );

  @override
  Base get get => this;

  @override
  Map<String, dynamic> get map => {
        'objectId': id,
        'title': title,
        'note': note,
        'mActivity': mActivityList,
        'isActive': isActive,
        'taskDateTime': taskDateTime?.toUtc(),
        'notificationDateTime': notificationDateTime?.toUtc(),
        'user': user,
        'hexColor': color?.toHex(),
        'taskRepeat': taskRepeat,
        'memory': memoryMapByDate.values.toList(),
      };

  static TaskParse from(ParseObject parseObject,
      {TaskParse cacheData,
      List<String> cacheKeys = const [],
      Map<String, Function> cacheTransform}) {
    if (parseObject == null) {
      return null;
    }
    final parseOptions = {
      'cacheData': cacheData,
      'cacheKeys': cacheKeys ?? [],
      'data': parseObject,
      'cacheTransform': cacheTransform ?? {}
    };
    return TaskParse(
      id: ParseMixin.value('objectId', parseOptions),
      note: ParseMixin.value('note', parseOptions),
      title: ParseMixin.value('title', parseOptions),
      taskDateTime: ParseMixin.value('taskDateTime', parseOptions)?.toLocal(),
      notificationDateTime:
          ParseMixin.value('notificationDateTime', parseOptions)?.toLocal(),
      mActivityList: List<MActivity>.from(ParseMixin.value(
          'mActivity', parseOptions,
          transform: MActivityParse.from)),
      isActive: ParseMixin.value('isActive', parseOptions),
      user: ParseMixin.value('user', parseOptions),
      color: ParseMixin.value('hexColor', parseOptions,
          transform: HexColor.fromHex),
      taskRepeat: ParseMixin.value('taskRepeat', parseOptions,
          transform: TaskRepeatParse.from),
      memoryMapByDate: Map<DateTime, Memory>.fromEntries(
          List<MapEntry<DateTime, Memory>>.from(
              ParseMixin.value('memory', parseOptions, transform: (object) {
        if (object is ParseObject) {
          final memory = MemoryParse.from(object);
          return MapEntry(DateUtil.getDateOnly(memory.logDateTime), memory);
        }
        return object;
      }))),
    );
  }

  static Map<DateTime, List<Task>> subListMapByDate(
    List<Task> taskList,
  ) {
    Map<DateTime, Set<Task>> map = {};
    taskList.forEach((task) {
      var taskDateTime = DateUtil.getDateOnly(task.taskDateTime);
      if (map.containsKey(taskDateTime)) {
        map[taskDateTime].add(task);
      } else {
        map[taskDateTime] = [task].toSet();
      }
      if ((task.taskRepeat?.selectedDateList ?? []).isNotEmpty) {
        (task.taskRepeat.selectedDateList ?? []).forEach((taskDate) {
          taskDateTime = DateUtil.getDateOnly(taskDate);
          if (map.containsKey(taskDateTime)) {
            map[taskDateTime].add(task);
          } else {
            map[taskDateTime] = [task].toSet();
          }
        });
      }
    });
    final Map<DateTime, List<Task>> newMap = {};
    map.forEach((key, value) {
      newMap[key] = List<Task>.from(value.toList());
    });

    return newMap;
  }
}
