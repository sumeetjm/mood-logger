import 'package:mood_manager/features/mood_manager/data/models/parse/base_m_parse_mixin.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_activity.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class MActivityParse extends MActivity with BaseMParseMixin {
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

  factory MActivityParse.fromParseObject(ParseObject parseObject) {
    if (parseObject == null) {
      return null;
    }
    return MActivityParse(
        activityId: parseObject.get('objectId'),
        activityName: parseObject.get('name'),
        activityCode: parseObject.get('code'),
        isActive: parseObject.get('isActive'));
  }

  static List<MActivityParse> fromParseArray(List<dynamic> parseArray) {
    return (parseArray ?? [])
        .where((element) => (element as ParseObject).get('isActive'))
        .map((object) => MActivityParse.fromParseObject(object))
        .toList();
  }

  ParseObject toParseObject() {
    ParseObject parseObject = baseParseObject(this);
    return parseObject;
  }
}
