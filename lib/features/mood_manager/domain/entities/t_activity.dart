import 'package:flutter/material.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/base.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_activity.dart';

class TActivity extends Base {
  final MActivity mActivity;
  final DateTime auditDate;

  TActivity({
    String id,
    this.auditDate,
    @required this.mActivity,
    bool isActive = true,
  }) : super(
          id: id,
          isActive: isActive,
          className: 'tActivity',
        );

  @override
  List<Object> get props => [
        mActivity,
        ...super.props,
      ];
}
