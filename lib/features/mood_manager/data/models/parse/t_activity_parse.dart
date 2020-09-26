import 'package:mood_manager/features/mood_manager/data/models/parse/base_t_parse_mixin.dart';
import 'package:mood_manager/features/mood_manager/data/models/parse/m_activity_parse.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_activity.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_activity.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class TActivityParse extends TActivity with BaseTParseMixin {
  TActivityParse({
    String transActivityId,
    MActivity mActivity,
    bool isActive = true,
  }) : super(
          id: transActivityId,
          mActivity: mActivity,
          isActive: isActive,
        );

  factory TActivityParse.fromId(String transActivityId) {
    return TActivityParse(transActivityId: transActivityId);
  }

  factory TActivityParse.initial() {
    return TActivityParse(
        transActivityId: '',
        mActivity: MActivityParse.initial(),
        isActive: true);
  }

  factory TActivityParse.fromParseObject(ParseObject parseObject) {
    if (parseObject == null) {
      return null;
    }
    return TActivityParse(
        transActivityId: parseObject.get('objectId'),
        mActivity: MActivityParse.fromParseObject(parseObject.get('mActivity')),
        isActive: parseObject.get('isActive'));
  }

  static List<TActivityParse> fromParseArray(List<dynamic> parseArray) {
    return parseArray
        .where((element) => (element as ParseObject).get('isActive'))
        .map((parseObject) => TActivityParse.fromParseObject(parseObject))
        .toList();
  }

  ParseObject toParseObject() {
    ParseObject parseObject = baseParseObject(this);
    parseObject.set('mActivity', (mActivity as MActivityParse).toParseObject());
    return parseObject;
  }
}
