import 'package:mood_manager/features/mood_manager/domain/entities/base_m.dart';

class MActivityType extends BaseM {
  MActivityType(
      {String activityTypeId,
      String activityTypeName,
      String activityTypeCode,
      bool isActive})
      : super(
            id: activityTypeId,
            name: activityTypeName,
            code: activityTypeCode,
            isActive: isActive);
}
