import 'package:mood_manager/features/common/data/models/parse_mixin.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/reminder/data/models/task_parse.dart';
import 'package:mood_manager/features/reminder/domain/entities/task.dart';
import 'package:mood_manager/features/reminder/domain/entities/task_notification_mapping.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class TaskNotificationMappingParse extends TaskNotificationMapping
    with ParseMixin {
  TaskNotificationMappingParse({
    String id,
    Task task,
    DateTime notifyDateTime,
    int localNotificationId,
    bool isActive = true,
    bool isAfterTask = false,
  }) : super(
            id: id,
            isActive: isActive,
            localNotificationId: localNotificationId,
            notifyDateTime: notifyDateTime,
            task: task,
            isAfterTask: isAfterTask);

  @override
  Base get get => this;

  @override
  Map<String, dynamic> get map => {
        'objectId': id,
        'isActive': isActive,
        'localNotificationId': localNotificationId,
        'notifyDateTime': notifyDateTime?.toUtc(),
        'task': task,
        'isAfterTask': isAfterTask,
      };

  static TaskNotificationMappingParse from(ParseObject parseObject,
      {TaskNotificationMappingParse cacheData,
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
    return TaskNotificationMappingParse(
      id: ParseMixin.value('objectId', parseOptions),
      isActive: ParseMixin.value('isActive', parseOptions),
      localNotificationId:
          ParseMixin.value('localNotificationId', parseOptions),
      notifyDateTime:
          ParseMixin.value('notifyDateTime', parseOptions)?.toLocal(),
      task: ParseMixin.value('task', parseOptions, transform: TaskParse.from),
      isAfterTask: ParseMixin.value('isAfterTask', parseOptions),
    );
  }
}
