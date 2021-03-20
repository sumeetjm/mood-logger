import 'package:dartz/dartz.dart' show cast;
import 'package:mood_manager/core/error/exceptions.dart';
import 'package:mood_manager/features/common/data/models/parse_mixin.dart';
import 'package:mood_manager/features/reminder/data/models/task_parse.dart';
import 'package:mood_manager/features/reminder/domain/entities/task.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

abstract class TaskRemoteDataSource {
  Future<Task> saveTask(Task task);
  Future<List<Task>> getTaskList();
}

class TaskParseDataSource extends TaskRemoteDataSource {
  TaskParseDataSource();

  @override
  Future<List<Task>> getTaskList() async {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('task'))
          ..includeObject([
            'mActivity',
            'mActivity.mActivityType',
          ])
          ..whereEqualTo('isActive', true)
          ..whereEqualTo('user',
              ((await ParseUser.currentUser()) as ParseUser).toPointer())
          ..orderByDescending('taskDateTime');
    final ParseResponse response = await queryBuilder.query();
    if (response.success) {
      List<Task> taskList =
          ParseMixin.listFrom<Task>(response.results, TaskParse.from);
      return taskList;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<Task> saveTask(Task task) async {
    final memoryParse = cast<TaskParse>(task).toParse(
        pointerKeys: ['mActivity'], user: await ParseUser.currentUser());
    ParseResponse response = await memoryParse.save();
    if (response.success) {
      Task savedTask = TaskParse.from(response.result,
          cacheData: task, cacheKeys: ['mActivity']);
      return savedTask;
    } else {
      throw ServerException();
    }
  }
}
