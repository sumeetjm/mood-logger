import 'package:mood_manager/features/common/data/models/parse_mixin.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/metadata/data/models/m_activity_type_parse.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity_type.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class MActivityParse extends MActivity with ParseMixin {
  MActivityParse({
    String activityId,
    String activityName,
    String activityCode,
    MActivityType mActivityType,
    bool isActive = true,
    Map userPtr,
  }) : super(
          activityId: activityId,
          activityName: activityName,
          activityCode: activityCode,
          mActivityType: mActivityType,
          isActive: isActive,
          userPtr: userPtr,
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
      mActivityType: ParseMixin.value('mActivityType', parseOptions,
          transform: MActivityTypeParse.from),
      isActive: ParseMixin.value('isActive', parseOptions),
      userPtr: ParseMixin.value('user', parseOptions, transform: (object) {
        if (object is ParseObject) {
          return object?.toPointer();
        }
        return object;
      }),
    );
  }

  @override
  Base get get => this;

  @override
  Map<String, dynamic> get map => {
        'objectId': id,
        'name': activityName,
        'code': activityCode,
        'mActivityType': mActivityType,
        'isActive': isActive,
        'user': userPtr,
      };
}
