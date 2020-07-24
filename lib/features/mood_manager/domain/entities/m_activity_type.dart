import 'package:mood_manager/features/mood_manager/domain/entities/base_m.dart';

class MActivityType extends BaseM {
  MActivityType(
      {int activityTypeId,
      String activityTypeName,
      String activityTypeCode,
      bool isActive})
      : super(
            id: activityTypeId,
            name: activityTypeName,
            code: activityTypeCode,
            isActive: isActive);

  @override
  List<Object> get props => [id, name, code, isActive];
}
