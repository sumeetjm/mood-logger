import 'package:mood_manager/features/common/data/models/parse_mixin.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity_type.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class MActivityTypeParse extends MActivityType with ParseMixin {
  MActivityTypeParse({
    String activityTypeId,
    String activityTypeName,
    String activityTypeCode,
    bool isActive = true,
    Map userPtr,
  }) : super(
          activityTypeId: activityTypeId,
          activityTypeName: activityTypeCode,
          activityTypeCode: activityTypeCode,
          isActive: isActive,
          userPtr: userPtr,
        );

  factory MActivityTypeParse.fromId(String activityTypeId) {
    return MActivityTypeParse(activityTypeId: activityTypeId);
  }

  factory MActivityTypeParse.initial() {
    return MActivityTypeParse(
        activityTypeId: '',
        activityTypeName: '',
        activityTypeCode: '',
        isActive: true);
  }

  static MActivityTypeParse from(ParseObject parseObject,
      {MActivityTypeParse cacheData, List<String> cacheKeys = const []}) {
    if (parseObject == null) {
      return null;
    }
    final parseOptions = {
      'cacheData': cacheData,
      'cacheKeys': cacheKeys ?? [],
      'data': parseObject,
    };
    return MActivityTypeParse(
      activityTypeId: ParseMixin.value('objectId', parseOptions),
      activityTypeName: ParseMixin.value('name', parseOptions),
      activityTypeCode: ParseMixin.value('code', parseOptions),
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
        'name': activityTypeName,
        'code': activityTypeCode,
        'isActive': isActive,
        'user': userPtr,
      };
}
