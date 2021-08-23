import 'package:dartz/dartz.dart' show cast;
import 'package:mood_manager/core/error/exceptions.dart';
import 'package:mood_manager/core/util/date_util.dart';
import 'package:mood_manager/features/common/data/models/parse_mixin.dart';
import 'package:mood_manager/features/memory/data/datasources/memory_remote_data_source.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:mood_manager/features/reminder/data/datasources/task_notification_remote_data_source.dart';
import 'package:mood_manager/features/reminder/data/models/task_parse.dart';
import 'package:mood_manager/features/reminder/domain/entities/task.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

abstract class TaskRemoteDataSource {
  Future<Task> saveTask(Task task);
  Future<List<Task>> getTaskList();
  Future<Task> getTask(String taskId);
  Future<int> getTotalNoOfTasks();
}

class TaskParseDataSource extends TaskRemoteDataSource {
  final TaskNotificationRemoteDataSource taskNotificationSource;
  final MemoryRemoteDataSource memoryRemoteDataSource;
  TaskParseDataSource(
      {this.taskNotificationSource, this.memoryRemoteDataSource});

  @override
  Future<List<Task>> getTaskList() async {
    /*final taskBox = await Hive.openBox<Task>('task');
    if (taskBox.isEmpty) {*/
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('task'))
          ..includeObject([
            'mActivity',
            'mActivity.mActivityType',
            'taskRepeat',
            'memory',
            'memory.mMood',
            'memory.mMood.subMood',
            'memory.mActivity',
            'memory.mActivity.mActivityType',
            'memory.collection',
          ])
          ..whereEqualTo('isActive', true)
          ..whereEqualTo('user',
              ((await ParseUser.currentUser()) as ParseUser).toPointer())
          ..orderByDescending('taskDateTime');
    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      final List<Task> taskList =
          ParseMixin.listFrom<Task>(response.results, TaskParse.from);
      //taskBox.addAll(taskList);
      return taskList;
    } else {
      throw ServerException();
    }
    /*} else {
      return taskBox.values.toList();
    }*/
  }

  @override
  Future<Task> saveTask(Task task) async {
    final taskParse = cast<TaskParse>(task).toParse(
        pointerKeys: ['mActivity', 'memory'],
        user: await ParseUser.currentUser());
    ParseResponse response = await taskParse.save();
    if (response.success) {
      Task savedTask = TaskParse.from(
        response.result,
        cacheData: task,
        cacheKeys: ['mActivity', 'memory'],
        cacheTransform: {
          'memory': (List<Memory> memoryList) {
            return memoryList
                .map((e) => MapEntry(DateUtil.getDateOnly(e.logDateTime), e))
                .toList();
          },
        },
      );

      await taskNotificationSource.scheduleTaskNotification(savedTask);
      return savedTask;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<Task> getTask(final String taskId) async {
    /*final taskBox = await Hive.openBox<Task>('task');
    if (taskBox.get(taskId) == null) {*/
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('task'))
          ..includeObject([
            'mActivity',
            'mActivity.mActivityType',
            'taskRepeat',
            'memory',
            'memory.mMood',
            'memory.mMood.subMood',
            'memory.mActivity',
            'memory.mActivity.mActivityType',
            'memory.collection'
          ])
          ..whereEqualTo('isActive', true)
          ..whereEqualTo('objectId', taskId)
          ..whereEqualTo('user',
              ((await ParseUser.currentUser()) as ParseUser).toPointer())
          ..orderByDescending('taskDateTime');
    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      final taskParse = TaskParse.from(response.results?.first);
      return taskParse;
    } else {
      throw ServerException();
    }
    /*} else {
      return taskBox.get(taskId);
    }*/
  }

  @override
  Future<int> getTotalNoOfTasks() async {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('task'))
          ..whereEqualTo('isActive', true)
          ..whereEqualTo('user',
              ((await ParseUser.currentUser()) as ParseUser).toPointer())
          ..count();
    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      return response.count;
    } else {
      throw ServerException();
    }
  }
}
