import 'package:mood_manager/features/mood_manager/domain/entities/base_t.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_activity.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_mood.dart';

class TActivity extends BaseT {
  MActivity mActivity;
  TMood tMood;

  TActivity(
      {String id,
      DateTime auditDate,
      bool isActive,
      this.mActivity,
      this.tMood})
      : super(id: id, auditDate: auditDate, isActive: isActive);

  set setMActivity(MActivity mActivity) {
    this.mActivity = mActivity;
  }

  set setTMood(TMood tMood) => this.tMood = tMood;

  @override
  List<Object> get props => [mActivity, tMood, ...super.props];
}
