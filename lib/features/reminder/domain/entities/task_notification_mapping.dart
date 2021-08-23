import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/reminder/data/models/task_notification_mapping_parse.dart';
import 'package:mood_manager/features/reminder/domain/entities/task.dart';
import 'package:hive/hive.dart';

part 'task_notification_mapping.g.dart';

@HiveType(typeId: 14)
class TaskNotificationMapping extends Base {
  @HiveField(3)
  final Task task;
  @HiveField(4)
  final DateTime notifyDateTime;
  @HiveField(5)
  final int localNotificationId;
  @HiveField(6)
  final bool isAfterTask;

  TaskNotificationMapping({
    String id,
    this.task,
    this.notifyDateTime,
    this.localNotificationId,
    bool isActive = true,
    this.isAfterTask = false,
  }) : super(
          id: id,
          isActive: isActive,
          className: 'taskNotificationMapping',
        );

  @override
  List<Object> get props => [
        task,
        notifyDateTime,
        localNotificationId,
        isAfterTask,
        ...super.props,
      ];
}
