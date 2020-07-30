import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class BaseT extends Equatable {
  String id;
  DateTime auditDate;
  final bool isActive;

  BaseT({@required this.id, @required this.auditDate, @required this.isActive});

  @override
  List<Object> get props => [id, auditDate, isActive];
}
