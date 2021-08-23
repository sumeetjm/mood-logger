import 'package:dartz/dartz.dart' hide Task;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mood_manager/core/error/exceptions.dart';
import 'package:mood_manager/core/util/date_util.dart';
import 'package:mood_manager/features/common/data/models/parse_mixin.dart';
import 'package:mood_manager/features/reminder/data/models/task_notification_mapping_parse.dart';
import 'package:mood_manager/features/reminder/data/models/task_parse.dart';
import 'package:mood_manager/features/reminder/domain/entities/task.dart';
import 'package:mood_manager/features/reminder/domain/entities/task_notification_mapping.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:timezone/timezone.dart' as tz;

abstract class TaskNotificationRemoteDataSource {
  Future<void> scheduleTaskNotification(Task task);
  Future<void> cancelTaskNotification(int notificationId);
  Future<TaskNotificationMapping>
      getTaskNotificationMappingByNotificationmappingId(
          String notificationMappingId);
  Future<List<TaskNotificationMapping>>
      getTaskNotificationMappingByNotifyDateTime(DateTime notifyDateTime);
  Future<void> scheduleTimedTaskNotification(
      TaskNotificationMapping taskNotificationMapping);
}

class TaskNotificationRemoteDataSourceImpl
    extends TaskNotificationRemoteDataSource {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final NotificationDetails notificationDetails;
  final Future<tz.Location> locationFuture;
  TaskNotificationRemoteDataSourceImpl({
    this.flutterLocalNotificationsPlugin,
    this.notificationDetails,
    this.locationFuture,
  });

  Future<void> scheduleTimedNotification(DateTime notifyTime,
      int notificationId, Task task, String notificationMappingId) async {
    final scheduledDate = tz.TZDateTime.from(notifyTime, await locationFuture);
    if (DateTime.now().isBefore(notifyTime)) {
      return await flutterLocalNotificationsPlugin.zonedSchedule(notificationId,
          task.title, task.note, scheduledDate, notificationDetails,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidAllowWhileIdle: true,
          payload: notificationMappingId);
    }
  }

  @override
  Future<void> scheduleTaskNotification(Task task) async {
    final List<TaskNotificationMapping> taskNotificationMappingList =
        await getTaskNotificationMappingList(task);

    final deletedNotificationMappingList = task.isActive
        ? taskNotificationMappingList
            .where((taskNotificationMapping) =>
                !task.taskRepeat.selectedDateList.any((element) =>
                    taskNotificationMapping.notifyDateTime ==
                    DateUtil.combine(
                      element,
                      TimeOfDay.fromDateTime(task.notificationDateTime),
                    )))
            .toList()
        : taskNotificationMappingList;
    for (final notificationMappingToBeDeleted
        in deletedNotificationMappingList) {
      notificationMappingToBeDeleted.isActive = false;
      await cast<TaskNotificationMappingParse>(notificationMappingToBeDeleted)
          .toParse(pointerKeys: ['task']).save();
      cancelTaskNotification(
          notificationMappingToBeDeleted.localNotificationId);
    }
    if (task.isActive) {
      for (final date in task.taskRepeat.selectedDateList) {
        final notifyDateTime = DateUtil.combine(
          date,
          TimeOfDay.fromDateTime(task.notificationDateTime),
        );
        TaskNotificationMapping existingTaskNotificationMapping =
            await getTaskNotificationMapping(task, notifyDateTime);
        if (existingTaskNotificationMapping == null) {
          final queryBuilder = QueryBuilder.name('taskNotificationMapping')
            ..count();
          ParseResponse response = await queryBuilder.query();
          final notificationId = response.count + 1;
          response = await cast<TaskNotificationMappingParse>(
                  TaskNotificationMappingParse(
                      localNotificationId:
                          notifyDateTime.millisecondsSinceEpoch ~/ 1000,
                      notifyDateTime: notifyDateTime,
                      task: task))
              .toParse(pointerKeys: ['task']).save();
          await scheduleTimedNotification(notifyDateTime, notificationId, task,
              response.results.first.get('objectId'));
        }
      }
    }
  }

  @override
  Future<void> scheduleTimedTaskNotification(
      TaskNotificationMapping taskNotificationMapping) async {
    final queryBuilder = QueryBuilder.name('taskNotificationMapping')..count();
    ParseResponse response = await queryBuilder.query();
    final notificationId = response.count + 1;
    response = await cast<TaskNotificationMappingParse>(taskNotificationMapping)
        .toParse(pointerKeys: ['task']).save();

    await scheduleTimedNotification(
        taskNotificationMapping.notifyDateTime,
        notificationId,
        taskNotificationMapping.task,
        response.results.first.get('objectId'));
  }

  @override
  Future<void> cancelTaskNotification(int notificationId) {
    return flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  Future<List<TaskNotificationMapping>> getTaskNotificationMappingList(
      Task task) async {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('taskNotificationMapping'))
          ..whereEqualTo('isActive', true)
          ..whereEqualTo('task', cast<TaskParse>(task).pointer);
    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      final List<TaskNotificationMapping> taskList =
          ParseMixin.listFrom<TaskNotificationMapping>(response.results,
              (parseObject) {
        return TaskNotificationMappingParse.from(parseObject,
            cacheData: TaskNotificationMappingParse(task: task),
            cacheKeys: ['task']);
      });
      return taskList;
    } else {
      throw ServerException();
    }
  }

  Future<TaskNotificationMapping> getTaskNotificationMapping(
      Task task, DateTime dateTime) async {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('taskNotificationMapping'))
          ..whereEqualTo('isActive', true)
          ..whereEqualTo('task', cast<TaskParse>(task).pointer)
          ..whereEqualTo('notifyDateTime', dateTime.toUtc());
    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      return TaskNotificationMappingParse.from(response.results?.first,
          cacheData: TaskNotificationMappingParse(task: task),
          cacheKeys: ['task']);
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<TaskNotificationMapping>>
      getTaskNotificationMappingByNotifyDateTime(
          DateTime notifyDateTime) async {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('taskNotificationMapping'))
          ..whereEqualTo('isActive', true)
          ..whereLessThanOrEqualTo('notifyDateTime', notifyDateTime.toUtc())
          ..whereGreaterThan('notifyDateTime',
              notifyDateTime.subtract(Duration(minutes: 1)).toUtc())
          ..includeObject(['task', 'task.mActivity', 'task.taskRepeat']);
    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      return ParseMixin.listFrom(
          response.results ?? [], TaskNotificationMappingParse.from);
    } else {
      throw ServerException();
    }
  }

  @override
  Future<TaskNotificationMapping>
      getTaskNotificationMappingByNotificationmappingId(
          String notificationMappingId) async {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('taskNotificationMapping'))
          ..whereEqualTo('isActive', true)
          ..whereEqualTo('objectId', notificationMappingId)
          ..includeObject(['task', 'task.mActivity', 'task.taskRepeat']);
    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      return TaskNotificationMappingParse.from(response.results?.first);
    } else {
      throw ServerException();
    }
  }
}
