import 'package:mood_manager/features/mood_manager/data/models/parse/base_parse_mixin.dart';
import 'package:mood_manager/features/mood_manager/data/models/parse/collection_parse.dart';
import 'package:mood_manager/features/mood_manager/data/models/parse/m_activity_parse.dart';
import 'package:mood_manager/features/mood_manager/data/models/parse/m_mood_parse.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/base.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/collection.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_activity.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_mood.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/memory.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class MemoryParse extends Memory with ParseMixin {
  MemoryParse({
    String id,
    String note,
    MMood mMood,
    List<Collection> collectionList,
    List<MActivity> mActivityList,
    bool isActive = true,
    DateTime logDateTime,
  }) : super(
          id: id,
          note: note,
          mMood: mMood,
          mActivityList: mActivityList,
          collectionList: collectionList,
          isActive: isActive,
          logDateTime: logDateTime,
        );

  @override
  Base get get => this;

  @override
  Map<String, dynamic> get map => {
        'objectId': id,
        'note': note,
        'mMood': mMood,
        'mActivity': mActivityList,
        'collection': collectionList,
        'isActive': isActive,
        'logDateTime': logDateTime,
      };

  static MemoryParse from(ParseObject parseObject,
      {MemoryParse cacheData, List<String> cacheKeys = const []}) {
    if (parseObject == null) {
      return null;
    }
    final parseOptions = {
      'cacheData': cacheData,
      'cacheKeys': cacheKeys ?? [],
      'data': parseObject,
    };
    return MemoryParse(
      id: ParseMixin.value('objectId', parseOptions),
      note: ParseMixin.value('note', parseOptions),
      logDateTime: ParseMixin.value('logDateTime', parseOptions),
      mMood:
          ParseMixin.value('mMood', parseOptions, transform: MMoodParse.from),
      collectionList: List<Collection>.from(ParseMixin.value(
          'collection', parseOptions,
          transform: CollectionParse.from)),
      mActivityList: List<MActivity>.from(ParseMixin.value(
          'mActivity', parseOptions,
          transform: MActivityParse.from)),
      isActive: ParseMixin.value('isActive', parseOptions),
    );
  }
}
