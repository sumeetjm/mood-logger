import 'package:mood_manager/features/common/data/models/parse_mixin.dart';
import 'package:mood_manager/features/common/data/models/media_collection_parse.dart';
import 'package:mood_manager/features/metadata/data/models/m_activity_parse.dart';
import 'package:mood_manager/features/metadata/data/models/m_mood_parse.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_mood.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class MemoryParse extends Memory with ParseMixin {
  MemoryParse({
    String id,
    String note,
    MMood mMood,
    List<MediaCollection> collectionList,
    List<MActivity> mActivityList,
    bool isActive = true,
    DateTime logDateTime,
    bool isArchived = false,
    ParseUser user,
  }) : super(
          id: id,
          note: note,
          mMood: mMood,
          mActivityList: mActivityList,
          mediaCollectionList: collectionList,
          isActive: isActive,
          logDateTime: logDateTime,
          isArchived: isArchived,
          user: user,
        );

  @override
  Base get get => this;

  @override
  Map<String, dynamic> get map => {
        'objectId': id,
        'note': note,
        'mMood': mMood,
        'mActivity': mActivityList,
        'collection': mediaCollectionList,
        'isActive': isActive,
        'logDateTime': logDateTime?.toUtc(),
        'isArchived': isArchived,
        'user': user,
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
      logDateTime: ParseMixin.value('logDateTime', parseOptions)?.toLocal(),
      mMood:
          ParseMixin.value('mMood', parseOptions, transform: MMoodParse.from),
      collectionList: List<MediaCollection>.from(ParseMixin.value(
              'collection', parseOptions,
              transform: MediaCollectionParse.from) ??
          []),
      mActivityList: List<MActivity>.from(ParseMixin.value(
          'mActivity', parseOptions,
          transform: MActivityParse.from)),
      isActive: ParseMixin.value('isActive', parseOptions),
      isArchived: ParseMixin.value('isArchived', parseOptions),
      user: ParseMixin.value('user', parseOptions),
    );
  }
}
