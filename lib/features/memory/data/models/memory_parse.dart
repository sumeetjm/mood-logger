import 'package:mood_manager/core/constants/app_constants.dart';
import 'package:mood_manager/features/common/data/models/parse_mixin.dart';
import 'package:mood_manager/features/common/data/models/media_collection_parse.dart';
import 'package:mood_manager/features/metadata/data/models/m_activity_parse.dart';
import 'package:mood_manager/features/metadata/data/models/m_mood_parse.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_mood.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:mood_manager/features/reminder/domain/entities/task.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class MemoryParse extends Memory with ParseMixin {
  MemoryParse({
    String id,
    String title,
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
          title: title,
          note: note,
          mMood: mMood,
          mActivityList: mActivityList,
          mediaCollectionList: collectionList,
          isActive: isActive,
          logDateTime: logDateTime,
          user: user,
        );

  @override
  Base get get => this;

  @override
  Map<String, dynamic> get map => {
        'objectId': id,
        'title': title,
        'note': note,
        'mMood': mMood ?? AppConstants.dummyMood,
        'mActivity': mActivityList,
        'mediaCollection': mediaCollectionList,
        'isActive': isActive,
        'logDateTime': logDateTime?.toUtc(),
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
      title: ParseMixin.value('title', parseOptions),
      note: ParseMixin.value('note', parseOptions),
      logDateTime: ParseMixin.value('logDateTime', parseOptions)?.toLocal(),
      mMood:
          ParseMixin.value('mMood', parseOptions, transform: MMoodParse.from),
      collectionList: List<MediaCollection>.from(ParseMixin.value(
              'mediaCollection', parseOptions,
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

  static MemoryParse fromTask(
      Task task, DateTime selectedDate, List<MActivity> mActivityList) {
    return MemoryParse(
      logDateTime: selectedDate,
      title: task.title,
      note: task.note,
      mActivityList: mActivityList,
    );
  }
}
