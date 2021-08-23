import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:hive/hive.dart';
import 'package:mood_manager/features/reminder/data/models/task_repeat_parse.dart';

part 'task_repeat.g.dart';

@HiveType(typeId: 12)
class TaskRepeat extends Base {
  @HiveField(3)
  final String repeatType;
  @HiveField(4)
  List<DateTime> selectedDateList;
  @HiveField(5)
  final DateTime validUpto;
  @HiveField(6)
  List<DateTime> markedDoneDateList;

  TaskRepeat({
    String id,
    this.repeatType,
    this.selectedDateList,
    this.markedDoneDateList,
    bool isActive,
    this.validUpto,
  }) : super(
          id: id,
          isActive: isActive,
          className: 'taskRepeat',
        );

  @override
  List<Object> get props => [
        repeatType,
        selectedDateList,
        validUpto,
        markedDoneDateList,
        ...super.props,
      ];
}
