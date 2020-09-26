import 'package:flutter/material.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/base_t.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_activity.dart';

class TActivity extends BaseT {
  final MActivity mActivity;

  TActivity({
    String id,
    DateTime auditDate,
    bool isActive = true,
    @required this.mActivity,
  }) : super(
          id: id,
          auditDate: auditDate,
          isActive: isActive,
          className: 'tActivity',
        );

  @override
  List<Object> get props => [
        mActivity,
        ...super.props,
      ];
}
