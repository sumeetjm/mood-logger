import 'package:flutter/material.dart';
import 'package:mood_manager/core/constants.dart/app_constants.dart';
import 'package:mood_manager/core/util/color_util.dart';
import 'package:mood_manager/features/mood_manager/data/datasources/m_mood_remote_data_source.dart';
import 'package:mood_manager/features/mood_manager/data/models/m_mood_model.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_mood.dart';
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
  Future<List<MMood>> mMoodListFuture;

  @override
  void initState() {
    super.initState();
    mMoodRemoteDataSource = sl<MMoodRemoteDataSource>();
    mMoodListFuture = mMoodRemoteDataSource
        .getMMoodListByIds(widget.tMoodList.map((e) => e.mMood.id).toList());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MMood>>(
      initialData: widget.tMoodList.map((e) => MMoodModel.initial()).toList(),
      future: mMoodListFuture,
      builder: (context, snapshot) {
        final mMoodList = snapshot.data;
        return Container(
            height: 30,
            decoration: new BoxDecoration(
                color: ColorUtil.mix(mMoodList.map((e) => e.color).toList()),
                borderRadius: new BorderRadius.only(
                  topLeft: const Radius.circular(15.0),
                  topRight: const Radius.circular(15.0),
                )),
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
      },
    );
  }
}
