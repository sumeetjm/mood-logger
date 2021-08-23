import 'package:flutter/material.dart';
import 'package:mood_manager/features/common/data/models/media_parse.dart';
import 'package:mood_manager/features/metadata/data/models/gender_parse.dart';
import 'package:mood_manager/features/metadata/data/models/m_mood_parse.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_mood.dart';
import 'package:mood_manager/features/metadata/domain/entities/gender.dart';

class AppConstants {
  static const HEADER_DATE_FORMAT = 'dd MMMM yyyy';
  static const TASK_VIEW_DATE_FORMAT = 'dd MMMM yyyy H:mm aa';
  static const ACTION = {'ADD': 'A', 'UPDATE': 'U', 'DELETE': 'D'};
  // ignore: non_constant_identifier_names
  static final DEFAULT_PROFILE_MEDIA = MediaParse(
      id: '1yIIfoos6n',
      file: null,
      thumbnail: null,
      mediaType: 'PHOTO',
      dominantColor: Colors.white);
  static const DEFAULT_PROFILE_PIC =
      'https://mlrjx6kefml3.i.optimole.com/6AH3zQ-wlC6a5CH/w:300/h:300/q:auto/dpr:1.3/rt:fill/g:ce/https://stratefix.com/wp-content/uploads/2016/04/dummy-profile-pic-male1.jpg';
  static final List<Gender> genderList = [
    GenderParse(
      id: 'FlSLK2bKOC',
      name: 'Not disclosed',
      code: 'X',
      isActive: true,
      altName: 'Not disclosed',
      iconKey: null,
    ),
    GenderParse(
      id: 'aXTXI7G2v1',
      name: 'Male',
      code: 'M',
      isActive: true,
      altName: 'Men',
      iconKey: "genderMale",
    ),
    GenderParse(
      id: 'MCwNrDA48M',
      name: 'Female',
      code: 'F',
      isActive: true,
      altName: 'Women',
      iconKey: "genderFemale",
    ),
    GenderParse(
      id: 'BXaxjbCbN8',
      name: 'Other',
      code: 'O',
      isActive: true,
      altName: 'Other',
      iconKey: "genderNonBinary",
    )
  ];
  static const NO_SPECIAL_CHARACTER_REGEX =
      '^[a-zA-Z]+(([\',. -][a-zA-Z ])?[a-zA-Z]*)*\$';
  static const EMAIL_REGEX =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  static const bool allowVideoTrimming = false;
  static const bool trimVideoBeforeAdd = false;
  static const Duration videoDurationAllowed = Duration(minutes: 2);
  static const bool allowImageCropping = true;
  static const bool cropImageBeforeAdd = false;
  static final MMood dummyMood =
      MMoodParse();
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
