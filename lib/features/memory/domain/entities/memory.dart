import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_mood.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class Memory extends Base {
  final String note;
  final MMood mMood;
  final List<MediaCollection> mediaCollectionList;
  final List<MActivity> mActivityList;
  final DateTime logDateTime;
  bool isArchived;
  ParseUser user;

  Memory({
    String id,
    this.note,
    this.mMood,
    this.mActivityList,
    this.mediaCollectionList,
    bool isActive = true,
    this.logDateTime,
    this.isArchived,
    this.user,
  }) : super(
          id: id,
          isActive: isActive,
          className: 'memory',
        );

  @override
  List<Object> get props => [
        note,
        mMood,
        mActivityList,
        mediaCollectionList,
        isArchived,
        ...super.props
      ];
}
