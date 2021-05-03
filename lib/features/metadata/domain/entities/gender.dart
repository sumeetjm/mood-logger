import 'package:flutter/material.dart';
import 'package:mood_manager/core/util/common_util.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:hive/hive.dart';
import 'package:mood_manager/features/metadata/data/models/gender_parse.dart';

part 'gender.g.dart';

@HiveType(typeId: 6)
class Gender extends Base {
  @HiveField(3)
  final String altName;
  @HiveField(4)
  final String name;
  @HiveField(5)
  final String code;
  @HiveField(6)
  final bool isDummy;
  @HiveField(7)
  final IconData iconData;

  Gender({
    @required String id,
    @required this.name,
    @required this.code,
    @required this.altName,
    @required this.iconData,
    this.isDummy = false,
    bool isActive = true,
  }) : super(
          id: id,
          isActive: isActive,
          className: 'gender',
        );

  @override
  List<Object> get props => [...super.props, name, code, altName];
}
