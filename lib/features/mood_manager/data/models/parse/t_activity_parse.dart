import 'package:mood_manager/features/common/data/models/parse_mixin.dart';
import 'package:mood_manager/features/metadata/data/models/m_activity_parse.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_activity.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class TActivityParse extends TActivity with ParseMixin {
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

  static TActivityParse from(ParseObject parseObject,
      {TActivityParse cacheData, List<String> cacheKeys = const []}) {
    if (parseObject == null) {
      return null;
    }
    final parseOptions = {
      'cacheData': cacheData,
      'cacheKeys': cacheKeys ?? [],
      'data': parseObject,
    };
    ;
    return TActivityParse(
        transActivityId: ParseMixin.value('objectId', parseOptions),
        mActivity: ParseMixin.value('mActivity', parseOptions,
            transform: MActivityParse.from),
        isActive: ParseMixin.value('isActive', parseOptions));
  }

  @override
  Base get get => this;

  @override
  Map<String, dynamic> get map =>
      {'objectId': id, 'mActivity': mActivity, 'isActive': isActive};
}
