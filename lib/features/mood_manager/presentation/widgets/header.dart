import 'package:flutter/material.dart';
import 'package:mood_manager/core/constants/app_constants.dart';
import 'package:mood_manager/core/util/color_util.dart';
import 'package:mood_manager/features/metadata/data/datasources/m_mood_remote_data_source.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_mood.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:intl/intl.dart';

class DateHeader extends StatefulWidget {
  const DateHeader({
    Key key,
    @required this.tMoodList,
  }) : super(key: key);

  final List<TMood> tMoodList;

  @override
  State<StatefulWidget> createState() => DateHeaderState();
}

class DateHeaderState extends State<DateHeader> {
  MMoodRemoteDataSource mMoodRemoteDataSource;

  @override
  void initState() {
    super.initState();
    mMoodRemoteDataSource = sl<MMoodRemoteDataSource>();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 30,
        decoration: BoxDecoration(
          color: ColorUtil.mix(
              widget.tMoodList.map((e) => e.mMood.color).toList()),
        ),
        child: Center(
            child: Text(
          DateFormat(AppConstants.HEADER_DATE_FORMAT)
              .format(widget.tMoodList[0].logDateTime),
          style: TextStyle(
              color: Colors.grey[50],
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic),
        )));
  }
}
