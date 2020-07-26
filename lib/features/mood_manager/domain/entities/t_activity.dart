import 'package:mood_manager/features/mood_manager/domain/entities/base_t.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_activity.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_mood.dart';

class TActivity extends BaseT {
  final String transActivityId;
  MActivity mActivity;
  TMood tMood;

  TActivity(
      {this.transActivityId,
      DateTime auditDate,
      bool isActive,
      this.mActivity,
      this.tMood})
      : super(auditDate: auditDate, isActive: isActive);

  set setMActivity(MActivity mActivity) {
    this.mActivity = mActivity;
  }

  set setTMood(TMood tMood) => this.tMood = tMood;

  @override
  List<Object> get props => [transActivityId, mActivity, ...super.props];
}
