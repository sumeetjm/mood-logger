import 'package:mood_manager/features/mood_manager/data/models/parse/base_parse_mixin.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/base.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_activity.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class MActivityParse extends MActivity with ParseMixin {
  MActivityParse({
    String activityId,
    String activityName,
    String activityCode,
    bool isActive = true,
  }) : super(
          activityId: activityId,
          activityName: activityName,
          activityCode: activityCode,
          isActive: isActive,
        );

  factory MActivityParse.fromId(String activityId) {
    return MActivityParse(activityId: activityId);
  }

  factory MActivityParse.initial() {
    return MActivityParse(
        activityId: '', activityCode: '', activityName: '', isActive: true);
  }

  static MActivityParse from(ParseObject parseObject,
      {MActivityParse cacheData, List<String> cacheKeys = const []}) {
    if (parseObject == null) {
      return null;
    }
    final parseOptions = {
      'cacheData': cacheData,
      'cacheKeys': cacheKeys ?? [],
      'data': parseObject,
    };
    return MActivityParse(
      activityId: ParseMixin.value('objectId', parseOptions),
      activityName: ParseMixin.value('name', parseOptions),
      activityCode: ParseMixin.value('code', parseOptions),
      isActive: ParseMixin.value('isActive', parseOptions),
    );
  }

  @override
  Base get get => this;

  @override
  Map<String, dynamic> get map => {
        'objectId': id,
        'name': activityName,
        'code': activityCode,
        'isActive': isActive,
      };
}
