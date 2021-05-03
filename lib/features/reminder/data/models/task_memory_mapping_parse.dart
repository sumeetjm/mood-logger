import 'package:mood_manager/features/common/data/models/parse_mixin.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/memory/data/models/memory_parse.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:mood_manager/features/reminder/data/models/task_parse.dart';
import 'package:mood_manager/features/reminder/domain/entities/task.dart';
import 'package:mood_manager/features/reminder/domain/entities/task_memory_mapping.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class TaskMemoryMappingParse extends TaskMemoryMapping with ParseMixin {
  TaskMemoryMappingParse({
    String id,
    bool isActive = true,
    DateTime date,
    Memory memory,
    Task task,
  }) : super(
          id: id,
          isActive: isActive,
          date: date,
          memory: memory,
          task: task,
        );

  @override
  Base get get => this;

  @override
  Map<String, dynamic> get map => {
        'objectId': id,
        'isActive': isActive,
        'date': date?.toUtc(),
        'memory': memory,
        'task': task,
      };

  static TaskMemoryMappingParse from(ParseObject parseObject,
      {TaskMemoryMappingParse cacheData, List<String> cacheKeys = const []}) {
    if (parseObject == null) {
      return null;
    }
    final parseOptions = {
      'cacheData': cacheData,
      'cacheKeys': cacheKeys ?? [],
      'data': parseObject,
    };
    return TaskMemoryMappingParse(
      id: ParseMixin.value('objectId', parseOptions),
      isActive: ParseMixin.value('isActive', parseOptions),
      date: ParseMixin.value('date', parseOptions)?.toLocal(),
      memory:
          ParseMixin.value('memory', parseOptions, transform: MemoryParse.from),
      task: ParseMixin.value('task', parseOptions, transform: TaskParse.from),
    );
  }
}
