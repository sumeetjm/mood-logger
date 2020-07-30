import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mood_manager/core/constants.dart/app_constants.dart';
import 'package:intl/intl.dart';
import 'package:mood_manager/features/mood_manager/data/datasources/m_mood_remote_data_source.dart';
import 'package:mood_manager/features/mood_manager/data/models/m_mood_model.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_mood.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_mood.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/header.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/t_mood_slidable_row.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:provider/provider.dart';

class TMoodSlidable extends StatefulWidget {
  TMoodSlidable({
    Key key,
    this.tMoodListMapByDate,
    @required this.deleteCallback,
    @required this.editCallback,
    @required this.refreshCallback,
  }) : super(key: key);

  final Map<DateTime, List<TMood>> tMoodListMapByDate;
  final Function deleteCallback;
  final Function editCallback;
  final Function refreshCallback;
  @override
  _TMoodSlidableState createState() => _TMoodSlidableState();
}

class _TMoodSlidableState extends State<TMoodSlidable> {
  Map<DateTime, Future<List<MMood>>> mMoodMapByDate = Map();
  SlidableController slidableController;
  MMoodRemoteDataSource mMoodRemoteDataSource;
  @protected
  void initState() {
    slidableController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );
    super.initState();
    mMoodRemoteDataSource = sl<MMoodRemoteDataSource>();
    widget.tMoodListMapByDate.forEach((key, value) async {
      mMoodMapByDate[key] =
          mMoodRemoteDataSource.getMMoodListByIds(value.map((e) => e.mMood.id));
    });
    //debugger();
  }

  void handleSlideAnimationChanged(Animation<double> slideAnimation) {
    //setState(() {});
  }

  void handleSlideIsOpenChanged(bool isOpen) {
    //setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OrientationBuilder(
        builder: (context, orientation) => _buildList(
            context,
            orientation == Orientation.portrait
                ? Axis.vertical
                : Axis.horizontal),
      ),
    );
  }

  Widget _buildList(BuildContext context, Axis direction) {
    return RefreshIndicator(
      onRefresh: widget.refreshCallback,
      child: ListView.builder(
        scrollDirection: direction,
        itemBuilder: (context, index) {
          final Axis slidableDirection = Axis.horizontal;
          return _getSlidableWithDelegates(
              context, index, slidableDirection, widget.tMoodListMapByDate);
        },
        itemCount: widget.tMoodListMapByDate.length,
      ),
    );
  }

  Widget _getSlidableWithDelegates(BuildContext context, int index,
      Axis direction, Map<DateTime, List<TMood>> map) {
    var dateKey = map.keys.toList()[index];
    var tMoodListDayWise = map[dateKey];
    return Card(
      child: Column(children: [
        if (tMoodListDayWise.length > 0)
          FutureProvider<List<MMood>>.value(
              initialData:
                  tMoodListDayWise.map((e) => MMoodModel.initial()).toList(),
              value: mMoodMapByDate[dateKey],
              child: DateHeader(tMoodList: tMoodListDayWise)),
        ...tMoodListDayWise
            .map((tMood) => TMoodSlidableRow(
                tMood: tMood,
                editCallback: () {
                  widget.editCallback(tMood);
                },
                slidableController: slidableController,
                direction: direction,
                deleteCallback: () {
                  //debugger(when: false);
                  setState(() {
                    widget.tMoodListMapByDate[dateKey].remove(tMood);
                    if (widget.tMoodListMapByDate[dateKey].isEmpty) {
                      widget.tMoodListMapByDate.remove(dateKey);
                    }
                    widget.deleteCallback(dateKey, tMood);
                  });
                }))
            .toList()
      ]),
    );
  }
}
