import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mood_manager/core/util/color_util.dart';
import 'package:mood_manager/features/mood_manager/data/models/t_mood_model.dart';
import 'package:mood_manager/features/mood_manager/data/streams/stream_service.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_mood.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_mood.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/t_mood_slidable_row.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class TMoodEventCalendar extends StatefulWidget {
  TMoodEventCalendar(
      {Key key, @required this.deleteCallback, @required this.editCallback})
      : super(key: key) {
    this.selectedDate = getDateOnly(DateTime.now());
  }

  DateTime selectedDate;
  final Function deleteCallback;
  final Function editCallback;
  DateTime getDateOnly(DateTime dateTime) {
    return DateFormat(DateFormat.YEAR_NUM_MONTH_DAY)
        .parse(DateFormat(DateFormat.YEAR_NUM_MONTH_DAY).format(dateTime));
  }

  @override
  _TMoodEventCalendarState createState() => _TMoodEventCalendarState();
}

class _TMoodEventCalendarState extends State<TMoodEventCalendar>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  CalendarController _calendarController;
  SlidableController slidableController;

  void handleSlideAnimationChanged(Animation<double> slideAnimation) {
    setState(() {});
  }

  void handleSlideIsOpenChanged(bool isOpen) {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    slidableController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );
    _calendarController = CalendarController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime date, List events) {
    print('CALLBACK: _onDaySelected');
    setState(() {
      widget.selectedDate = date;
    });
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }

  void _onCalendarCreated(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onCalendarCreated');
  }

  @override
  Widget build(BuildContext context) {
    final tMoodListMapByDateList =
        Provider.of<List<MapEntry<DateTime, List<TMood>>>>(context) ?? [];
    final Map<DateTime, List<TMood>> tMoodListMapByDate =
        Map.fromEntries(tMoodListMapByDateList);
    return SingleChildScrollView(
      child: Container(
        height: 500 +
            90.0 *
                (tMoodListMapByDate[widget.getDateOnly(widget.selectedDate)] ??
                        [])
                    .length,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            // Switch out 2 lines below to play with TableCalendar's settings
            //-----------------------
            //_buildTableCalendar(),
            _buildTableCalendarWithBuilders(tMoodListMapByDate),
            const SizedBox(height: 8.0),
            Expanded(child: _buildEventList(tMoodListMapByDate)),
          ],
        ),
      ),
    );
  }

  // Simple TableCalendar configuration (using Styles)
  Widget _buildTableCalendar(Map<DateTime, List<TMood>> tMoodListMapByDate) {
    debugger();
    return TableCalendar(
      endDay: DateTime.now(),
      calendarController: _calendarController,
      events: tMoodListMapByDate,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        selectedColor: Colors.deepOrange[400],
        todayColor: Colors.deepOrange[200],
        markersColor: Colors.brown[700],
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        formatButtonTextStyle:
            TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
        formatButtonDecoration: BoxDecoration(
          color: Colors.deepOrange[400],
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      onDaySelected: _onDaySelected,
      onVisibleDaysChanged: _onVisibleDaysChanged,
      onCalendarCreated: _onCalendarCreated,
    );
  }

  // More advanced TableCalendar configuration (using Builders & Styles)
  Widget _buildTableCalendarWithBuilders(
      Map<DateTime, List<TMood>> tMoodListMapByDate) {
    //debugger();
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 0))),
      child: TableCalendar(
        endDay: DateTime.now(),
        locale: 'en_US',
        calendarController: _calendarController,
        events: tMoodListMapByDate,
        initialCalendarFormat: CalendarFormat.month,
        formatAnimation: FormatAnimation.slide,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        availableGestures: AvailableGestures.all,
        availableCalendarFormats: const {
          CalendarFormat.month: '',
          CalendarFormat.week: '',
          CalendarFormat.twoWeeks: '',
        },
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendStyle: TextStyle().copyWith(color: Colors.blue[800]),
          holidayStyle: TextStyle().copyWith(color: Colors.blue[800]),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekendStyle: TextStyle().copyWith(color: Colors.blue[600]),
        ),
        headerStyle: HeaderStyle(
          centerHeaderTitle: true,
          formatButtonVisible: false,
        ),
        builders: CalendarBuilders(
          selectedDayBuilder: (context, date, _) {
            return FadeTransition(
              opacity:
                  Tween(begin: 0.0, end: 1.0).animate(_animationController),
              child: Container(
                margin: const EdgeInsets.all(4.0),
                padding: const EdgeInsets.only(top: 5.0, left: 6.0),
                color: Colors.deepOrange[300],
                width: 100,
                height: 100,
                child: Text(
                  '${date.day}',
                  style: TextStyle().copyWith(fontSize: 16.0),
                ),
              ),
            );
          },
          todayDayBuilder: (context, date, _) {
            return Container(
              margin: const EdgeInsets.all(4.0),
              padding: const EdgeInsets.only(top: 5.0, left: 6.0),
              color: Colors.amber[400],
              width: 100,
              height: 100,
              child: Text(
                '${date.day}',
                style: TextStyle().copyWith(fontSize: 16.0),
              ),
            );
          },
          markersBuilder: (context, date, events, holidays) {
            final children = <Widget>[];
            //debugger();
            if (events.isNotEmpty) {
              children.add(
                Positioned(
                  right: 1,
                  bottom: 1,
                  child: _buildEventsMarker(date, events),
                ),
              );
            }

            if (holidays.isNotEmpty) {
              children.add(
                Positioned(
                  right: -2,
                  top: -2,
                  child: _buildHolidaysMarker(),
                ),
              );
            }

            return children;
          },
        ),
        onDaySelected: (date, events) {
          _onDaySelected(date, events);
          _animationController.forward(from: 0.0);
        },
        onVisibleDaysChanged: _onVisibleDaysChanged,
        onCalendarCreated: _onCalendarCreated,
      ),
    );
  }

  Widget _buildEventsMarker(DateTime date, List<TMoodModel> events) {
    return StreamBuilder<List<MMood>>(
        stream: sl<StreamService>().mMoodList(events),
        initialData: [],
        builder: (context, snapshot) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color:
                    ColorUtil.mix(snapshot.data.map((e) => e.color).toList())),
            width: 16.0,
            height: 16.0,
            child: Center(
              child: Text(
                '${events.length}',
                style: TextStyle().copyWith(
                  color: Colors.white,
                  fontSize: 12.0,
                ),
              ),
            ),
          );
        });
  }

  Widget _buildHolidaysMarker() {
    return Icon(
      Icons.add_box,
      size: 20.0,
      color: Colors.blueGrey[800],
    );
  }

  Widget _buildEventList(Map<DateTime, List<TMood>> tMoodListMapByDate) {
    return Column(
      children: (tMoodListMapByDate[widget.getDateOnly(widget.selectedDate)] ??
              [])
          .map((item) => StreamProvider.value(
                value: Stream.value(item),
                child: TMoodSlidableRow(
                  slidableController: slidableController,
                  direction: Axis.horizontal,
                  deleteCallback: () {
                    widget.deleteCallback(
                        widget.getDateOnly(widget.selectedDate), item);
                    tMoodListMapByDate[widget.getDateOnly(widget.selectedDate)]
                        .remove(item);
                    tMoodListMapByDate[widget.getDateOnly(widget.selectedDate)]
                        .remove(item);
                  },
                  editCallback: () {
                    widget.editCallback(item);
                  },
                ),
              ))
          .toList(),
    );
  }
}
