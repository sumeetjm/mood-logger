import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

abstract class BaseM extends Equatable {
  final String id;
  final String name;
  final String code;
  final bool isActive;
  final String className;

  BaseM({
    @required this.id,
    @required this.name,
    @required this.code,
    @required this.isActive,
    @required this.className,
  });

  @override
  List<Object> get props => [
        id,
        name,
        code,
        isActive,
      ];
}
