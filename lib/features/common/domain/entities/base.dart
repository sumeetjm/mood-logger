import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

abstract class Base extends Equatable {
  final String id;
  final bool isActive;
  final String className;

  Base({
    @required this.id,
    @required this.isActive,
    @required this.className,
  });

  @override
  List<Object> get props => [id, isActive, className];
}
