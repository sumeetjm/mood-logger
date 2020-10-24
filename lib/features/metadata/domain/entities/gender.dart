import 'package:flutter/material.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';

class Gender extends Base {
  final String altName;
  final String name;
  final String code;
  final bool isDummy;
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
