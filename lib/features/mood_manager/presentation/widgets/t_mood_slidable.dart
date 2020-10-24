import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mood_manager/core/util/date_util.dart';
import 'package:mood_manager/features/mood_manager/data/datasources/m_mood_remote_data_source.dart';
import 'package:mood_manager/features/mood_manager/data/models/parse/t_mood_parse.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_mood.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/animation_util.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/header.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/t_mood_slidable_row.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class TMoodSlidable extends StatefulWidget {
  TMoodSlidable(
      {Key key,
      this.tMoodList,
      @required this.deleteCallback,
      @required this.editCallback,
      @required this.refreshCallback,
      @required this.scrollController})
      : super(key: key) {
    this.tMoodListMapByDate = TMoodParse.subListMapByDate(tMoodList);
  }

  final List<TMood> tMoodList;
  Map<DateTime, List<TMood>> tMoodListMapByDate;
  final Function deleteCallback;
  final Function editCallback;
  final Function refreshCallback;
  final AutoScrollController scrollController;
  @override
  _TMoodSlidableState createState() => _TMoodSlidableState();
}

class _TMoodSlidableState extends State<TMoodSlidable> {
  Map<DateTime, List<TMood>> tMoodListMapByDate;
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
  }

  void handleSlideAnimationChanged(Animation<double> slideAnimation) {
    setState(() {});
  }

  void handleSlideIsOpenChanged(bool isOpen) {
    setState(() {});
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
    List<DateTime> dateKeys = widget.tMoodListMapByDate.keys.toList();
    final Axis slidableDirection = Axis.horizontal;

    return RefreshIndicator(
        onRefresh: widget.refreshCallback,
        child: AnimateIfVisibleWrapper(
            showItemInterval: Duration(milliseconds: 50),
            child: ListView.builder(
              addRepaintBoundaries: true,
              physics: BouncingScrollPhysics(),
              scrollDirection: direction,
              itemCount: (widget.tMoodListMapByDate ?? {}).length,
              controller: widget.scrollController,
              itemBuilder: (context, index) {
                var tMoodList = widget.tMoodListMapByDate[dateKeys[index]];
                return StickyHeader(
                  header: AnimateIfVisible(
                    duration: Duration(milliseconds: 100),
                    key: Key('${dateKeys[index]}'),
                    builder: animationBuilder(
                      DateHeader(
                        tMoodList: widget.tMoodListMapByDate[
                            DateUtil.getDateOnly(dateKeys[index])],
                      ),
                    ),
                  ),
                  content: Column(
                    children: tMoodList
                        .asMap()
                        .keys
                        .map(
                          (i) => _wrapScrollTag(
                            highlightColor: tMoodList[i].mMood.color,
                            index: widget.tMoodList.indexWhere(
                                (element) => element.id == tMoodList[i].id),
                            child: AnimateIfVisible(
                                duration: Duration(milliseconds: 100),
                                key: Key('${tMoodList[i].id + 'list'}'),
                                builder: animationBuilder(TMoodSlidableRow(
                                    tMood: tMoodList[i],
                                    editCallback: () {
                                      widget.editCallback(tMoodList[i]);
                                    },
                                    slidableController: slidableController,
                                    direction: slidableDirection,
                                    deleteCallback: () {
                                      final dateOnly = DateUtil.getDateOnly(
                                          tMoodList[i].logDateTime);
                                      widget.tMoodListMapByDate[dateOnly]
                                          .remove(tMoodList[i]);
                                      if (widget.tMoodListMapByDate[dateOnly]
                                          .isEmpty) {
                                        widget.tMoodListMapByDate
                                            .remove(dateOnly);
                                      }
                                      tMoodList.remove(tMoodList[i]);
                                      widget.deleteCallback(
                                          dateOnly, tMoodList[i]);
                                    }))),
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            )));
  }

  Widget _wrapScrollTag({int index, Widget child, Color highlightColor}) =>
      AutoScrollTag(
        key: ValueKey(index),
        controller: widget.scrollController,
        index: index,
        child: child,
        highlightColor: highlightColor.withOpacity(0.3),
      );

  Widget _wrapAnimatedBuilder({Widget child}) {}

  Widget _getSlidableWithDelegates(BuildContext context, int index,
      Axis direction, Map<DateTime, List<TMood>> map) {
    //
    var dateKey = map.keys.toList()[index];
    var tMoodListDayWise = map[dateKey];

    return Card(
      child: Column(children: [
        if (tMoodListDayWise.length > 0)
          DateHeader(tMoodList: tMoodListDayWise),
        ...tMoodListDayWise
            .map((tMood) => TMoodSlidableRow(
                tMood: tMood,
                editCallback: () {
                  widget.editCallback(tMood);
                },
                slidableController: slidableController,
                direction: direction,
                deleteCallback: () {
                  tMoodListMapByDate[dateKey].remove(tMood);
                  if (tMoodListMapByDate[dateKey].isEmpty) {
                    tMoodListMapByDate.remove(dateKey);
                  }
                  widget.deleteCallback(dateKey, tMood);
                }))
            .toList()
      ]),
    );
  }
}
