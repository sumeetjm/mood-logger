import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class BaseM extends Equatable {
  final int id;
  final String name;
  final String code;
  final bool isActive;

  BaseM({
    @required this.id,
    @required this.name,
    @required this.code,
    @required this.isActive,
  });

  @override
  List<Object> get props => [id, name, code, isActive];
}
