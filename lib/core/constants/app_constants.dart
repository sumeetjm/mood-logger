import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mood_manager/features/metadata/data/models/gender_parse.dart';
import 'package:mood_manager/features/metadata/domain/entities/gender.dart';

class AppConstants {
  static const HEADER_DATE_FORMAT = 'dd MMMM yyyy';
  static const ACTION = {'ADD': 'A', 'UPDATE': 'U', 'DELETE': 'D'};
  static const DEFAULT_PROFILE_PIC =
      'https://mlrjx6kefml3.i.optimole.com/6AH3zQ-wlC6a5CH/w:300/h:300/q:auto/dpr:1.3/rt:fill/g:ce/https://stratefix.com/wp-content/uploads/2016/04/dummy-profile-pic-male1.jpg';
  static final List<Gender> genderList = [
    GenderParse(
      id: null,
      name: 'Not disclosed',
      code: '',
      isActive: true,
      altName: '',
      iconData: null,
      isDummy: true,
    ),
    GenderParse(
      id: 'aXTXI7G2v1',
      name: 'Male',
      code: 'M',
      isActive: true,
      altName: 'Men',
      iconData: MdiIcons.genderMale,
    ),
    GenderParse(
      id: 'MCwNrDA48M',
      name: 'Female',
      code: 'F',
      isActive: true,
      altName: 'Women',
      iconData: MdiIcons.genderFemale,
    ),
    GenderParse(
      id: 'BXaxjbCbN8',
      name: 'Other',
      code: 'O',
      isActive: true,
      altName: 'Other',
      iconData: MdiIcons.genderNonBinary,
    )
  ];
  static const NO_SPECIAL_CHARACTER_REGEX =
      '^[a-zA-Z]+(([\',. -][a-zA-Z ])?[a-zA-Z]*)*\$';
  static const EMAIL_REGEX =
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";

  static final Map dataConstants = {'gender': genderList};
  //static final String thumbnailFolderPath = "/storage/emulated/0/Android/"

  static final List<Map> wallLayoutStoneMap = [
    {
      'height': 1,
      'width': 1,
    },
    {
      'height': 2,
      'width': 1,
    },
    {
      'height': 1,
      'width': 1,
    },
    {
      'height': 2,
      'width': 1,
    },
    {
      'height': 1,
      'width': 1,
    },
    {
      'height': 2,
      'width': 2,
    },
    {
      'height': 2,
      'width': 1,
    },
    {
      'height': 2,
      'width': 1,
    },
    {
      'height': 1,
      'width': 1,
    },
    {
      'height': 1,
      'width': 1,
    },
    {
      'height': 2,
      'width': 1,
    },
    {
      'height': 1,
      'width': 2,
    },
    {
      'height': 1,
      'width': 1,
    },
    {
      'height': 1,
      'width': 1,
    },
    {
      'height': 2,
      'width': 1,
    },
    {
      'height': 1,
      'width': 2,
    },
    {
      'height': 2,
      'width': 1,
    },
    {
      'height': 2,
      'width': 2,
    },
    {
      'height': 1,
      'width': 1,
    },
    {
      'height': 2,
      'width': 1,
    },
    {
      'height': 1,
      'width': 1,
    },
    {
      'height': 2,
      'width': 1,
    },
    {
      'height': 1,
      'width': 1,
    },
    {
      'height': 2,
      'width': 2,
    },
    {
      'height': 2,
      'width': 1,
    },
    {
      'height': 2,
      'width': 1,
    },
    {
      'height': 1,
      'width': 1,
    },
    {
      'height': 1,
      'width': 1,
    },
    {
      'height': 2,
      'width': 1,
    },
    {
      'height': 1,
      'width': 2,
    },
    {
      'height': 1,
      'width': 1,
    },
    {
      'height': 1,
      'width': 1,
    },
    {
      'height': 2,
      'width': 1,
    },
    {
      'height': 1,
      'width': 2,
    },
    {
      'height': 2,
      'width': 1,
    },
    {
      'height': 2,
      'width': 2,
    },
  ];
}
