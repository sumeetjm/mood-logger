import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

//@HiveType(typeId: 0)
abstract class Base with EquatableMixin {
  @HiveField(0)
  final String id;
  @HiveField(1)
  bool isActive;
  @HiveField(2)
  final String className;

  Base({
    @required this.id,
    @required this.isActive,
    @required this.className,
  });

  @override
  List<Object> get props => [id, isActive, className];
}
