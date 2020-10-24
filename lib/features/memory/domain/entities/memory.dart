import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/common/domain/entities/collection.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_mood.dart';

class Memory extends Base {
  final String note;
  final MMood mMood;
  final List<Collection> collectionList;
  final List<MActivity> mActivityList;
  final DateTime logDateTime;

  Memory(
      {String id,
      this.note,
      this.mMood,
      this.mActivityList,
      this.collectionList,
      bool isActive = true,
      this.logDateTime})
      : super(
          id: id,
          isActive: isActive,
          className: 'memory',
        );

  @override
  List<Object> get props =>
      [note, mMood, mActivityList, collectionList, ...super.props];
}
