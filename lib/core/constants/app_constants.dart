import 'package:mood_manager/features/mood_manager/domain/entities/gender.dart';

class AppConstants {
  static const HEADER_DATE_FORMAT = 'dd MMMM yyyy';
  static const ACTION = {'ADD': 'A', 'UPDATE': 'U', 'DELETE': 'D'};
  static const DEFAULT_PROFILE_PIC =
      'https://mlrjx6kefml3.i.optimole.com/6AH3zQ-wlC6a5CH/w:300/h:300/q:auto/dpr:1.3/rt:fill/g:ce/https://stratefix.com/wp-content/uploads/2016/04/dummy-profile-pic-male1.jpg';
  static final List<Gender> genderList = [
    Gender(
      id: null,
      name: 'Male',
      code: 'M',
      isActive: true,
      altName: 'Men',
    ),
    Gender(
      id: null,
      name: 'Female',
      code: 'F',
      isActive: true,
      altName: 'Women',
    ),
    Gender(
      id: null,
      name: 'Other',
      code: 'O',
      isActive: true,
      altName: 'Other',
    )
  ];
}
