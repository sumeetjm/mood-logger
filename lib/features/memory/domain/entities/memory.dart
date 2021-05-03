import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/memory/data/models/memory_parse.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_mood.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:hive/hive.dart';

part 'memory.g.dart';

@HiveType(typeId: 9)
class Memory extends Base {
  @HiveField(3)
  final String title;
  @HiveField(4)
  final String note;
  @HiveField(5)
  final MMood mMood;
  @HiveField(6)
  final List<MediaCollection> mediaCollectionList;
  @HiveField(7)
  final List<MActivity> mActivityList;
  @HiveField(8)
  final DateTime logDateTime;
  ParseUser user;

  Memory({
    String id,
    this.title,
    this.note,
    this.mMood,
    this.mActivityList,
    this.mediaCollectionList,
    bool isActive = true,
    this.logDateTime,
    this.user,
  }) : super(
          id: id,
          isActive: isActive,
          className: 'memory',
        );

  @override
  List<Object> get props =>
      [title, note, mMood, mActivityList, mediaCollectionList, ...super.props];
}
