import 'package:mood_manager/features/common/data/models/parse_mixin.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/reminder/domain/entities/task_repeat.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class TaskRepeatParse extends TaskRepeat with ParseMixin {
  TaskRepeatParse({
    String id,
    bool isActive = true,
    String repeatType,
    List<DateTime> selectedDateList = const [],
    DateTime validUpto,
  }) : super(
          id: id,
          isActive: isActive,
          repeatType: repeatType,
          selectedDateList: selectedDateList,
          validUpto: validUpto,
        );

  @override
  Base get get => this;

  @override
  Map<String, dynamic> get map => {
        'objectId': id,
        'isActive': isActive,
        'repeatType': repeatType,
        'selectedDateList':
            (selectedDateList ?? []).map((e) => e?.toUtc()).toList(),
        'validUpto': validUpto?.toUtc(),
      };

  static TaskRepeatParse from(ParseObject parseObject,
      {TaskRepeatParse cacheData, List<String> cacheKeys = const []}) {
    if (parseObject == null) {
      return null;
    }
    final parseOptions = {
      'cacheData': cacheData,
      'cacheKeys': cacheKeys ?? [],
      'data': parseObject,
    };
    return TaskRepeatParse(
      id: ParseMixin.value('objectId', parseOptions),
      isActive: ParseMixin.value('isActive', parseOptions),
      repeatType: ParseMixin.value('repeatType', parseOptions),
      selectedDateList: List<DateTime>.from(ParseMixin.value(
              'selectedDateList', parseOptions, transform: (dynamic dateTime) {
            if (dateTime is DateTime) {
              return dateTime?.toLocal();
            }
            return dateTime;
          }) ??
          []),
      validUpto: ParseMixin.value('validUpto', parseOptions,
          transform: (dynamic dateTime) {
        if (dateTime is DateTime) {
          return dateTime?.toLocal();
        }
        return dateTime;
      }),
    );
  }
}
