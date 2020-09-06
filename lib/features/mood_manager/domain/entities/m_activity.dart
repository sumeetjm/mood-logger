import 'package:mood_manager/features/mood_manager/domain/entities/base_m.dart';

class MActivity extends BaseM {
  MActivity({
    activityId,
    activityName,
    activityCode,
    isActive = true,
  }) : super(
            id: activityId,
            name: activityName,
            code: activityCode,
            isActive: isActive);
}
