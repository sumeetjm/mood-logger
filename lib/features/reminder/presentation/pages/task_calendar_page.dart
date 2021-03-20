import 'package:chips_choice/chips_choice.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:mood_manager/core/util/date_util.dart';
import 'package:mood_manager/features/common/presentation/pages/activity_selection_page.dart';
import 'package:mood_manager/features/common/presentation/widgets/choice_chip_group_selection.dart';
import 'package:mood_manager/features/common/presentation/widgets/empty_widget.dart';
import 'package:mood_manager/features/common/presentation/widgets/time_picker.dart';
import 'package:mood_manager/features/memory/presentation/widgets/transparent_page_route.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity_type.dart';
import 'package:mood_manager/features/metadata/presentation/bloc/activity_bloc.dart';
import 'package:mood_manager/features/reminder/data/models/task_parse.dart';
import 'package:mood_manager/features/reminder/domain/entities/task.dart';
import 'package:mood_manager/features/reminder/presentation/bloc/task_bloc.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tinycolor/tinycolor.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class TaskCalendarPage extends StatefulWidget {
  @override
  _TaskCalendarPageState createState() => _TaskCalendarPageState();
}

class _TaskCalendarPageState extends State<TaskCalendarPage> {
  DateTime selectedDate = DateTime.now();
  CalendarController _calendarController;
  String uniqueKey;
  final Uuid uuid = sl<Uuid>();
  ActivityBloc _activityListBloc;
  List<MActivity> activityList = [];
  List<MActivity> selectedActivityList = [];
  List<MActivityType> activityTypeList = [];
  AutoScrollController scrollController;
  Color color = Colors.red;
  Color tempColor = Colors.red;
  bool isAddMode = false;
  TextEditingController noteController = TextEditingController();
  TextEditingController timeBeforeController = TextEditingController();
  TaskBloc _taskBloc;
  List<Task> taskList = [];
  bool isNotify = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    uniqueKey = uuid.v1();
    _calendarController = CalendarController();
    _activityListBloc = sl<ActivityBloc>();
    _activityListBloc.add(GetActivityListEvent());
    _activityListBloc.add(GetActivityTypeListEvent());
    scrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);
    _taskBloc = sl<TaskBloc>();
    _taskBloc.add(GetTaskListEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your tasks"),
      ),
      floatingActionButton: FloatingActionButton(
          heroTag: uniqueKey,
          onPressed: () {
            setState(() {
              isAddMode = true;
              _calendarController.setCalendarFormat(CalendarFormat.week);
            });
          },
          child: Icon(
            Icons.add,
          )),
      body: Column(
        children: [
          _buildTableCalendarWithBuilders(),
          Expanded(
            child: ListView(
                physics: BouncingScrollPhysics(),
                controller: scrollController,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      color: color.withOpacity(0.2),
                      child: Column(
                        children: [
                          if (isAddMode)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                RaisedButton(
                                    color:
                                        TinyColor(Theme.of(context).buttonColor)
                                            .brighten(40)
                                            .color,
                                    child: Text(
                                        'Activities (${selectedActivityList.length})'),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          TransparentRoute(
                                              builder: (context) =>
                                                  ActivitySelectionPage(
                                                    selectedActivityList:
                                                        selectedActivityList,
                                                    onChange: (value) {
                                                      setState(() {
                                                        selectedActivityList =
                                                            value;
                                                      });
                                                    },
                                                  )));
                                    }),
                                TimePicker(
                                  selectedTime:
                                      TimeOfDay.fromDateTime(selectedDate),
                                  selectTime: (time) {
                                    setState(() {
                                      selectedDate = DateTimeField.combine(
                                          selectedDate, time);
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.done),
                                  onPressed: () async {
                                    _taskBloc.add(SaveTaskEvent(
                                        task: TaskParse(
                                      color: color,
                                      mActivityList: selectedActivityList,
                                      note: noteController.text,
                                      taskDateTime: selectedDate,
                                      user: await ParseUser.currentUser(),
                                    )));
                                  },
                                ),
                                IconButton(
                                    icon: Icon(Icons.close),
                                    onPressed: () {
                                      setState(() {
                                        isAddMode = false;
                                      });
                                    }),
                              ],
                            ),
                          if (isAddMode)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: "Your task",
                                ),
                                controller: noteController,
                              ),
                            ),
                          if (isAddMode)
                            ChipsChoice<MActivity>.multiple(
                              itemConfig: ChipsChoiceItemConfig(),
                              value: selectedActivityList,
                              options: ChipsChoiceOption.listFrom<MActivity,
                                  MActivity>(
                                source: selectedActivityList ?? [],
                                value: (i, v) => v,
                                label: (i, v) => v.activityName,
                              ),
                              onChanged: (List<MActivity> value) {},
                              isWrapped: true,
                            ),
                          if (isAddMode)
                            Row(
                              children: [
                                RaisedButton.icon(
                                    color:
                                        TinyColor(Theme.of(context).buttonColor)
                                            .brighten(40)
                                            .color,
                                    onPressed: () async {
                                      _openMainColorPicker(context);
                                    },
                                    icon: Icon(Icons.color_lens),
                                    label: Text('Select color')),
                                Switch(
                                    value: isNotify,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.padded,
                                    onChanged: (value) {
                                      setState(() {
                                        isNotify = value;
                                      });
                                    }),
                                Text(
                                    '${isNotify ? 'Notify' : 'Do not notify'}'),
                              ],
                            ),
                          if (isAddMode)
                            TextField(
                              decoration: InputDecoration(
                                hintText: "Time before notification",
                              ),
                              keyboardType: TextInputType.number,
                              controller: timeBeforeController,
                            ),
                        ],
                      ),
                    ),
                  ),
                  BlocConsumer<TaskBloc, TaskState>(
                    cubit: _taskBloc,
                    builder: (context, state) {
                      return Column(
                        children: taskList
                            .map((e) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Card(
                                    child: Container(
                                      color: e.color.withOpacity(0.2),
                                      height: 75,
                                      child: ListTile(
                                        title: Container(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(e.note)),
                                        subtitle: Container(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(e.mActivityList
                                                .map((e) => e.activityName)
                                                .join(' | '))),
                                        isThreeLine: false,
                                        trailing: Text(
                                            DateFormat(DateFormat.HOUR_MINUTE)
                                                .format(e.taskDateTime),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[800],
                                            )),
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      );
                    },
                    listener: (context, state) {
                      if (state is TaskListLoaded) {
                        taskList = state.taskList;
                      }
                    },
                  )
                ]),
          ),
        ],
      ),

      /*Column(
        children: [
          _buildTableCalendarWithBuilders(),
          Expanded(
            child: ListView(
                physics: BouncingScrollPhysics(),
                controller: ScrollController(),
                children: [
                  Column(
                    children: [
                      ListView(
                        shrinkWrap: true,
                        physics: AlwaysScrollableScrollPhysics(),
                        children: [
                          TimePicker(
                            selectedTime: TimeOfDay.fromDateTime(selectedDate),
                            selectTime: (time) {
                              setState(() {
                                selectedDate =
                                    DateTimeField.combine(selectedDate, time);
                              });
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              decoration: InputDecoration(
                                  hintText: "Your task",
                                  border: InputBorder.none),
                            ),
                          ),
                          BlocConsumer(
                            cubit: _activityListBloc,
                            builder: (context, state) {
                              if (activityList.isEmpty ||
                                  activityTypeList.isEmpty) {
                                return EmptyWidget();
                              } else {
                                if (state is ActivityLoading) {
                                  return EmptyWidget();
                                } else {
                                  return buildChoiceChipGroupSelection();
                                }
                              }
                            },
                            listener: (context, state) {
                              if (state is ActivityListLoaded) {
                                activityList = state.activityList;
                              } else if (state is ActivityTypeListLoaded) {
                                activityTypeList = state.activityTypeList;
                              } else if (state is ActivityListLoading ||
                                  state is ActivityLoading) {}
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ]),
          ),
        ],
      ),*/
    );
  }

  buildChoiceChipGroupSelection() {
    return ChoiceChipGroupSelection(
      maxSelection: 3,
      choiceChipOptions:
          ChoiceChipGroupSelectionOption.listFrom<MActivity, MActivity>(
              source: activityList,
              value: (index, item) => item,
              label: (index, item) => item.activityName,
              group: (index, item) => item.mActivityType),
      groupLabel: (group) => group.activityTypeName,
      initialValue: selectedActivityList,
      onChange: (activityList) {
        setState(() {
          selectedActivityList = List.from(activityList);
        });
      },
      groupList: activityTypeList,
    );
  }

  Widget _buildTableCalendarWithBuilders() {
    //
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 0)),
        color: Colors.white,
      ),
      child: TableCalendar(
        //endDay: DateTime.now(),
        locale: 'en_US',
        calendarController: _calendarController,
        //events: tMoodListMapByDate,
        initialCalendarFormat: CalendarFormat.month,
        initialSelectedDay: selectedDate,
        formatAnimation: FormatAnimation.slide,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        availableGestures: AvailableGestures.all,
        availableCalendarFormats: const {
          CalendarFormat.month: 'Month',
          CalendarFormat.week: 'Week',
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
          formatButtonVisible: true,
        ),
        builders: CalendarBuilders(
          selectedDayBuilder: (context, date, _) {
            return Container(
              margin: const EdgeInsets.all(4.0),
              padding: const EdgeInsets.only(top: 5.0, left: 6.0),
              color:
                  TinyColor(Theme.of(context).primaryColor).lighten(40).color,
              width: 100,
              height: 100,
              child: Text(
                '${date.day}',
                style: TextStyle(color: Colors.white).copyWith(fontSize: 16.0),
              ),
            );
          },
          todayDayBuilder: (context, date, _) {
            return Container(
              margin: const EdgeInsets.all(4.0),
              padding: const EdgeInsets.only(top: 5.0, left: 6.0),
              color:
                  TinyColor(Theme.of(context).primaryColor).lighten(60).color,
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
            //
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
          //_animationController.forward(from: 0.0);
        },
        onVisibleDaysChanged: _onVisibleDaysChanged,
        onCalendarCreated: _onCalendarCreated,
      ),
    );
  }

  Widget _buildHolidaysMarker() {
    return Icon(
      Icons.add_box,
      size: 20.0,
      color: Colors.blueGrey[800],
    );
  }

  void _onDaySelected(DateTime date, List events) {
    print('CALLBACK: _onDaySelected');
    setState(() {
      if (DateUtil.isSameDate(date, DateTime.now())) {
        selectedDate = DateTime.now();
      } else {
        selectedDate = date;
      }
    });
  }

  Widget _buildEventsMarker(DateTime date, List<dynamic> events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(shape: BoxShape.rectangle, color: Colors.red),
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
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }

  void _onCalendarCreated(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onCalendarCreated');
  }

  void _openDialog(String title, Widget content, context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        child: content,
        height: 175,
      ),
    );
    /*showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(6.0),
          title: Text(title),
          content: content,
          actions: [
            FlatButton(
              child: Text('CANCEL'),
              onPressed: Navigator.of(context).pop,
            ),
            FlatButton(
              child: Text('SUBMIT'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() => color = tempColor);
                // setState(() => _shadeColor = _tempShadeColor);
              },
            ),
          ],
        );
      },
    );*/
  }

  void _openMainColorPicker(context) async {
    _openDialog(
        "Main Color picker",
        MaterialColorPicker(
          selectedColor: color,
          allowShades: false,
          circleSize: 30,
          onMainColorChange: (color) => setState(() => this.color = color),
        ),
        context);
  }
}
