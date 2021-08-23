import 'dart:io';

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

class BaseUtil {
  static isEmpty(List list) {
    return list.where((element) => element.isActive).isEmpty;
  }

  static isNotEmpty(List list) {
    return !isEmpty(list);
  }

  static renameFileSync(File file, String name) {
    return file.renameSync(file.parent.path +
          "/" +
          name +
          file.path.substring(file.path.lastIndexOf(".")));
  }
}
