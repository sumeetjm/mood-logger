import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mood_manager/core/constants.dart/app_constants.dart';
import 'package:mood_manager/core/util/color_util.dart';
import 'package:intl/intl.dart';
import 'package:mood_manager/features/mood_manager/data/streams/stream_service.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_mood.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/empty_widget.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/header.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/t_mood_slidable_row.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:provider/provider.dart';

class TMoodSlidable extends StatefulWidget {
  TMoodSlidable({
    Key key,
    // @required this.tMoodListGroupByDate,
    @required this.deleteCallback,
    @required this.editCallback,
    @required this.refreshCallback,
  }) : super(key: key) {
    //dateList = tMoodListGroupByDate.keys.toList();
    //subLists = tMoodListGroupByDate.values.toList();
  }

  //final Map<DateTime, List<TMood>> tMoodListGroupByDate;
  /*List<DateTime> dateList;
  List<List<TMood>> subLists;*/
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
    final List<MapEntry<DateTime, List<TMood>>> tMoodListMapByDateList =
        Provider.of<List<MapEntry<DateTime, List<TMood>>>>(context) ?? [];
    return RefreshIndicator(
      onRefresh: widget.refreshCallback,
      child: ListView.builder(
        scrollDirection: direction,
        itemBuilder: (context, index) {
          final Axis slidableDirection = Axis.horizontal;
          return _getSlidableWithDelegates(
              context, index, slidableDirection, tMoodListMapByDateList);
        },
        itemCount: tMoodListMapByDateList.length,
      ),
    );
  }

  Widget _getSlidableWithDelegates(BuildContext context, int index,
      Axis direction, List<MapEntry<DateTime, List<TMood>>> entries) {
    var tMoodListDayWise = entries[index].value;
    return Card(
      child: Column(children: [
        if (tMoodListDayWise.length > 0)
          StreamProvider<Color>.value(
            value: sl<StreamService>().headerColor(tMoodListDayWise),
            child: DateHeader(
                text: DateFormat(AppConstants.HEADER_DATE_FORMAT)
                    .format(entries[index].key)),
          ),
        ...tMoodListDayWise
            .map((item) => StreamProvider<TMood>.value(
                  initialData: item,
                  value: Stream.value(item),
                  child: TMoodSlidableRow(
                      editCallback: () {
                        widget.editCallback(item);
                      },
                      //  tMood: item,
                      slidableController: slidableController,
                      direction: direction,
                      deleteCallback: () {
                        setState(() {
                          widget.deleteCallback(entries[index].key, item);
                        });
                      }),
                ))
            .toList()
      ]),
    );
  }
}
