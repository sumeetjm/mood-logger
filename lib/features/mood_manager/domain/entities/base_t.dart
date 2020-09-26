import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

abstract class BaseT extends Equatable {
  final String id;
  final DateTime auditDate;
  final bool isActive;
  final String className;

  BaseT({
    @required this.id,
    @required this.auditDate,
    @required this.isActive,
    @required this.className,
  });

  @override
  List<Object> get props => [
        id,
        auditDate,
        isActive,
      ];
}
