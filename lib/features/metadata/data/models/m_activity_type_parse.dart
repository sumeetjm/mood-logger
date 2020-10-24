import 'package:mood_manager/features/common/data/models/parse_mixin.dart';
import 'package:mood_manager/features/metadata/data/models/m_activity_parse.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity_type.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class MActivityTypeParse extends MActivityType with ParseMixin {
  MActivityTypeParse({
    String activityTypeId,
    String activityTypeName,
    String activityTypeCode,
    bool isActive = true,
    List<MActivity> mActivityList,
  }) : super(
          activityTypeId: activityTypeId,
          activityTypeName: activityTypeCode,
          activityTypeCode: activityTypeCode,
          mActivityList: mActivityList,
          isActive: isActive,
        );

  factory MActivityTypeParse.fromId(String activityTypeId) {
    return MActivityTypeParse(activityTypeId: activityTypeId);
  }

  factory MActivityTypeParse.initial() {
    return MActivityTypeParse(
        activityTypeId: '',
        activityTypeName: '',
        activityTypeCode: '',
        mActivityList: [],
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
      mActivityList: List<MActivity>.from(ParseMixin.value(
          'mActivity', parseOptions,
          transform: MActivityParse.from)),
    );
  }

  @override
  Base get get => this;

  @override
  Map<String, dynamic> get map => {
        'objectId': id,
        'name': activityTypeName,
        'code': activityTypeCode,
        'mActivity': mActivityList,
        'isActive': isActive
      };
}
