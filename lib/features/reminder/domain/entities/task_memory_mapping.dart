import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:mood_manager/features/reminder/data/models/task_memory_mapping_parse.dart';
import 'package:mood_manager/features/reminder/domain/entities/task.dart';
import 'package:hive/hive.dart';

part 'task_memory_mapping.g.dart';

@HiveType(typeId: 13)
class TaskMemoryMapping extends Base {
  @HiveField(3)
  final Task task;
  @HiveField(4)
  final Memory memory;
  @HiveField(5)
  final DateTime date;

  TaskMemoryMapping({
    String id,
    bool isActive = true,
    this.task,
    this.memory,
    this.date,
  }) : super(
          id: id,
          isActive: isActive,
          className: 'taskMemoryMapping',
        );

  @override
  List<Object> get props => [
        task,
        memory,
        date,
        ...super.props,
      ];
}
