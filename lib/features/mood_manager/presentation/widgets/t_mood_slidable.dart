import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mood_manager/core/constants.dart/app_constants.dart';
import 'package:mood_manager/core/util/color_util.dart';
import 'package:mood_manager/features/mood_manager/data/models/t_mood_model.dart';
import 'package:intl/intl.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/empty_widget.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/header.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/t_mood_row.dart';

class TMoodSlidable extends StatefulWidget {
  TMoodSlidable({
    Key key,
    @required this.tMoodListGroupByDate,
    @required this.deleteCallback,
    @required this.editCallback,
    @required this.refreshCallback,
  }) : super(key: key) {
    dateList = tMoodListGroupByDate.keys.toList();
    subLists = tMoodListGroupByDate.values.toList();
  }

  final Map<DateTime, List<TMoodModel>> tMoodListGroupByDate;
  List<DateTime> dateList;
  List<List<TMoodModel>> subLists;
  final Function deleteCallback;
  final Function editCallback;
  final Function refreshCallback;
  @override
  _TMoodSlidableState createState() => _TMoodSlidableState();
}

class _TMoodSlidableState extends State<TMoodSlidable> {
  SlidableController slidableController;
  @protected
  void initState() {
    slidableController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );
    super.initState();
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
    return RefreshIndicator(
      onRefresh: widget.refreshCallback,
      child: ListView.builder(
        scrollDirection: direction,
        itemBuilder: (context, index) {
          final Axis slidableDirection = Axis.horizontal;
          return _getSlidableWithDelegates(context, index, slidableDirection);
        },
        itemCount: widget.dateList.length,
      ),
    );
  }

  Widget _getSlidableWithDelegates(
      BuildContext context, int index, Axis direction) {
    final List<TMoodModel> tMoodList = widget.subLists[index];
    return Card(
      child: Column(children: [
        tMoodList.length > 0
            ? Header(
                color:
                    ColorUtil.mix(tMoodList.map((e) => e.mMood.color).toList()),
                text: DateFormat(AppConstants.HEADER_DATE_FORMAT)
                    .format(widget.dateList[index]))
            : EmptyWidget(),
        ...tMoodList
            .map((item) => TMoodSlidableRow(
                editCallback: () {
                  widget.editCallback(item);
                },
                tMoodModel: item,
                slidableController: slidableController,
                direction: direction,
                deleteCallback: () {
                  setState(() {
                    widget.deleteCallback(widget.dateList[index], item);
                  });
                }))
            .toList()
      ]),
    );
  }
}
