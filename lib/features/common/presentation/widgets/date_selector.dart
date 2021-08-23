import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tinycolor/tinycolor.dart';

// ignore: must_be_immutable
class DateSelector extends StatefulWidget {
  DateTime initialDate;
  ValueChanged<DateTime> selectDate;
  DateTime endDate;
  DateTime startDate;
  bool enabled;
  DateSelector({
    Key key,
    this.selectDate,
    this.initialDate,
    this.endDate,
    this.startDate,
    this.enabled = true,
  }) : super(key: key);

  @override
  _DateSelectorState createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  DateTime endDate = DateTime.now();
  List<DateTime> markedDates = [];
  CalendarController _calendarController;

  @override
  void initState() {
    super.initState();
    _calendarController = new CalendarController();
  }

  onSelect(data) {
    widget.selectDate(data);
  }

  getMarkedIndicatorWidget() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        margin: EdgeInsets.only(left: 1, right: 1),
        width: 7,
        height: 7,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red),
      ),
      Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
      )
    ]);
  }

  dateTileBuilder(
      date, selectedDate, rowIndex, dayName, isDateMarked, isDateOutOfRange) {
    bool isSelectedDate = date.compareTo(selectedDate) == 0;
    Color fontColor = isDateOutOfRange ? Colors.black26 : Colors.black87;
    TextStyle normalStyle =
        TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: fontColor);
    TextStyle selectedStyle = TextStyle(
        fontSize: 17, fontWeight: FontWeight.w800, color: Colors.black87);
    TextStyle dayNameStyle = TextStyle(fontSize: 14.5, color: fontColor);
    List<Widget> _children = [
      Text(dayName, style: dayNameStyle),
      Text(date.day.toString(),
          style: !isSelectedDate ? normalStyle : selectedStyle),
    ];

    if (isDateMarked == true) {
      _children.add(getMarkedIndicatorWidget());
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 8, left: 5, right: 5, bottom: 5),
      decoration: BoxDecoration(
        color: !isSelectedDate
            ? Colors.transparent
            : Theme.of(context).primaryColor.withOpacity(0.4),
        borderRadius: BorderRadius.all(Radius.circular(60)),
      ),
      child: Column(
        children: _children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildTableCalendar(),
      color: Colors.grey.withOpacity(0.2),
    );
  }

  Widget _buildTableCalendar() {
    return TableCalendar(
      initialSelectedDay: widget.initialDate,
      calendarController: _calendarController,
      initialCalendarFormat: CalendarFormat.week,
      availableCalendarFormats: {CalendarFormat.week: 'Week'},
      startDay: widget.startDate,
      endDay: widget.endDate,
      // events: _events,
      //holidays: _holidays,
      enabledDayPredicate: (day) => widget.enabled,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      calendarStyle: CalendarStyle(
        selectedColor: Theme.of(context).accentColor,
        todayColor: TinyColor(Theme.of(context).accentColor).lighten(20).color,
        markersColor: Colors.brown[700],
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        centerHeaderTitle: true,
        formatButtonTextStyle:
            TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
        formatButtonDecoration: BoxDecoration(
          color: Colors.deepOrange[400],
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      onDaySelected: (date, events, holidays) {
        onSelect(date);
      },
      onVisibleDaysChanged: _onVisibleDaysChanged,
      onCalendarCreated: _onCalendarCreated,
    );
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }

  void _onCalendarCreated(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onCalendarCreated');
  }
}
