import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:invert_colors/invert_colors.dart';
import 'package:mood_manager/core/util/color_util.dart';
import 'package:mood_manager/core/util/date_util.dart';
import 'package:mood_manager/features/common/domain/entities/base_states.dart';
import 'package:mood_manager/features/memory/presentation/bloc/memory_bloc.dart';
import 'package:mood_manager/features/memory/presentation/widgets/transparent_page_route.dart';
import 'package:mood_manager/features/reminder/data/datasources/task_notification_remote_data_source.dart';
import 'package:mood_manager/features/reminder/data/models/task_parse.dart';
import 'package:mood_manager/features/reminder/domain/entities/task.dart';
import 'package:mood_manager/features/reminder/presentation/bloc/task_bloc.dart';
import 'package:mood_manager/features/reminder/presentation/pages/task_form_page.dart';
import 'package:mood_manager/features/reminder/presentation/widgets/task_slidable_row.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tinycolor/tinycolor.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mood_manager/home.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class TaskCalendarPage extends StatefulWidget {
  @override
  _TaskCalendarPageState createState() => _TaskCalendarPageState();
}

class _TaskCalendarPageState extends State<TaskCalendarPage> {
  DateTime selectedDate = DateTime.now();
  CalendarController _calendarController;
  String uniqueKey;
  final Uuid uuid = sl<Uuid>();
  AutoScrollController scrollController;
  TaskBloc _taskBloc;
  MemoryBloc _memoryBloc;
  StreamSubscription subscription;
  List<Task> taskList = [];
  Map<DateTime, List<Task>> taskListMapByDate = {};
  SlidableController slidableController;

  @override
  void initState() {
    super.initState();
    uniqueKey = uuid.v1();
    _calendarController = CalendarController();
    scrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);
    _taskBloc = BlocProvider.of<TaskBloc>(context);
    _memoryBloc = BlocProvider.of<MemoryBloc>(context);
    subscription = _memoryBloc.listen(memoryBlocListener);
    _taskBloc.add(GetTaskListEvent());
    slidableController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  void memoryBlocListener(MemoryState state) {
    if (state is MemorySaved) {
      _taskBloc.add(GetTaskListEvent());
    }
  }

  void handleSlideAnimationChanged(Animation<double> slideAnimation) {
    setState(() {});
  }

  void handleSlideIsOpenChanged(bool isOpen) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final addWidgetButton = Container(
      height: 75,
      padding: EdgeInsets.all(8.0),
      child: TextButton(
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(Theme.of(context).primaryColor),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Text(
              'Add Task',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        onPressed: navigateToTaskForm,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            Provider.of<GlobalKey<ScaffoldState>>(context, listen: false)
                .currentState
                .openDrawer();
          },
        ),
        centerTitle: true,
        title: Text(
          "Tasks",
        ),
      ),
      floatingActionButton:
          (taskListMapByDate[DateUtil.getDateOnly(selectedDate)] ?? []).isEmpty
              ? null
              : FloatingActionButton(
                  heroTag: uniqueKey,
                  onPressed: navigateToTaskForm,
                  child: Icon(
                    Icons.add,
                  )),
      body: BlocConsumer<TaskBloc, TaskState>(
          cubit: _taskBloc,
          listener: (context, state) {
            if (state is TaskListLoaded) {
              taskList = state.taskList;
              taskListMapByDate = TaskParse.subListMapByDate(taskList);
            } else if (state is TaskSaved) {
              if (state.task.isActive) {
                Fluttertoast.showToast(
                    gravity: ToastGravity.TOP,
                    msg: 'Task saved successfully',
                    backgroundColor: Colors.green);
              } else {
                Fluttertoast.showToast(
                    gravity: ToastGravity.TOP,
                    msg: 'Task deleted successfully',
                    backgroundColor: Colors.green);
              }
              _taskBloc.add(GetTaskListEvent());
            } else if (state is TaskError) {
              Fluttertoast.showToast(
                  gravity: ToastGravity.TOP,
                  msg: state.message,
                  backgroundColor: Colors.red);
            }
            handleLoader(state, context);
          },
          builder: (context, state) {
            final taskListForSelectedDate =
                taskListMapByDate[DateUtil.getDateOnly(selectedDate)];
            return Column(
              children: [
                _buildTableCalendarWithBuilders(taskListMapByDate),
                if ((taskListForSelectedDate ?? []).isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(child: Text('No tasks')),
                  ),
                if ((taskListForSelectedDate ?? []).isEmpty) addWidgetButton,
                if ((taskListForSelectedDate ?? []).isNotEmpty)
                  Expanded(
                      child: AnimationLimiter(
                          child: ListView.builder(
                    itemCount: taskListForSelectedDate.length,
                    physics: BouncingScrollPhysics(),
                    controller: scrollController,
                    itemBuilder: (context, index) {
                      final e = taskListForSelectedDate[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 500),
                        child: SlideAnimation(
                          horizontalOffset: 50.0,
                          child: FadeInAnimation(
                              child: _wrapScrollTag(
                            highlightColor: e.color,
                            index:
                                taskList.indexWhere((element) => element == e),
                            child: TaskSlidableRow(
                              task: e,
                              slidableController: slidableController,
                              direction: Axis.horizontal,
                              deleteCallback: (isAllDates) async {
                                var removedTask =
                                    taskListForSelectedDate.removeAt(index);
                                if (isAllDates) {
                                  removedTask.isActive = false;
                                  _taskBloc
                                      .add(SaveTaskEvent(task: removedTask));
                                } else {
                                  removedTask.taskRepeat.selectedDateList
                                      .remove(
                                          DateUtil.getDateOnly(selectedDate));
                                  if (removedTask
                                      .taskRepeat.selectedDateList.isEmpty) {
                                    removedTask.isActive = false;
                                  }
                                  removedTask.taskRepeat.selectedDateList
                                      .sort((a, b) => a.compareTo(b));
                                  _taskBloc.add(SaveTaskEvent(
                                      task: TaskParse(
                                    color: removedTask.color,
                                    id: removedTask.id,
                                    isActive: removedTask
                                        .taskRepeat.selectedDateList.isNotEmpty,
                                    mActivityList: removedTask.mActivityList,
                                    memoryMapByDate:
                                        removedTask.memoryMapByDate,
                                    note: removedTask.note,
                                    notificationDateTime:
                                        removedTask.notificationDateTime,
                                    taskDateTime: DateUtil.combine(
                                        removedTask.taskRepeat.selectedDateList
                                                .isNotEmpty
                                            ? removedTask.taskRepeat
                                                .selectedDateList.first
                                            : removedTask.taskDateTime,
                                        TimeOfDay.fromDateTime(
                                            removedTask.taskDateTime)),
                                    taskRepeat: removedTask.taskRepeat,
                                    title: removedTask.title,
                                    user: removedTask.user,
                                  )));
                                }
                              },
                              editCallback: (Task task) {
                                Navigator.of(appNavigatorContext(context))
                                    .push(TransparentRoute(
                                  builder: (context) {
                                    return TaskFormPage(
                                      theme: Theme.of(context),
                                      selectedDate: task.taskDateTime,
                                      task: task,
                                      notificationDateTime:
                                          task.notificationDateTime,
                                    );
                                  },
                                ));
                              },
                              selectedDate: selectedDate,
                            ),
                          )),
                        ),
                      );
                    },
                  )))
                //..._buildEventList(
                //   taskListMapByDate[DateUtil.getDateOnly(selectedDate)]),
              ],
            );
          }),
    );
  }

  navigateToTaskForm() {
    setState(() {
      selectedDate =
          selectedDate.isBefore(DateTime.now()) ? DateTime.now() : selectedDate;
      _calendarController.setSelectedDay(selectedDate);
    });
    Navigator.of(appNavigatorContext(context)).push(TransparentRoute(
      builder: (context) {
        return TaskFormPage(
          theme: Theme.of(context),
          selectedDate: selectedDate.isBefore(DateTime.now())
              ? DateTime.now()
              : selectedDate,
        );
      },
    ));
  }

  Widget _buildTableCalendarWithBuilders(
      Map<DateTime, List<Task>> taskListMapByDate) {
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
        events: taskListMapByDate,
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
          weekendStyle:
              TextStyle().copyWith(color: Theme.of(context).accentColor),
          holidayStyle:
              TextStyle().copyWith(color: Theme.of(context).accentColor),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekendStyle:
              TextStyle().copyWith(color: Theme.of(context).accentColor),
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
              color: Theme.of(context).accentColor,
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
              color: TinyColor(Theme.of(context).accentColor).lighten(20).color,
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
        onDaySelected: (date, events, holidays) {
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
    Provider.of<GlobalKey<HomeState>>(context, listen: false)
        .currentState
        .setTaskCalendarSelectedDate(selectedDate);
  }

  Widget _buildEventsMarker(DateTime date, List<Task> events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: ColorUtil.mix(events.map((e) => e.color).toList())),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: InvertColors(
            child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: ColorUtil.mix(events.map((e) => e.color).toList()),
            fontSize: 12.0,
          ),
        )),
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

  Widget _wrapScrollTag({int index, Widget child, Color highlightColor}) =>
      AutoScrollTag(
        key: ValueKey(index),
        controller: scrollController,
        index: index,
        child: child,
        highlightColor: highlightColor.withOpacity(0.3),
      );

  List<Widget> _buildEventList(List<Task> taskList) {
    return (taskList ?? [])
        .asMap()
        .keys
        .map(
          (index) => _wrapScrollTag(
            highlightColor: taskList[index].color,
            index: index,
            child: TaskSlidableRow(
              task: taskList[index],
              slidableController: slidableController,
              direction: Axis.horizontal,
              deleteCallback: (isAllDates) async {
                var removedTask = taskList.removeAt(index);
                if (isAllDates) {
                  removedTask.isActive = false;
                  _taskBloc.add(SaveTaskEvent(task: removedTask));
                } else {
                  removedTask.taskRepeat.selectedDateList
                      .remove(DateUtil.getDateOnly(selectedDate));
                  if (removedTask.taskRepeat.selectedDateList.isEmpty) {
                    removedTask.isActive = false;
                  }
                  removedTask.taskRepeat.selectedDateList
                      .sort((a, b) => a.compareTo(b));
                  _taskBloc.add(SaveTaskEvent(
                      task: TaskParse(
                    color: removedTask.color,
                    id: removedTask.id,
                    isActive:
                        removedTask.taskRepeat.selectedDateList.isNotEmpty,
                    mActivityList: removedTask.mActivityList,
                    memoryMapByDate: removedTask.memoryMapByDate,
                    note: removedTask.note,
                    notificationDateTime: removedTask.notificationDateTime,
                    taskDateTime: DateUtil.combine(
                        removedTask.taskRepeat.selectedDateList.isNotEmpty
                            ? removedTask.taskRepeat.selectedDateList.first
                            : removedTask.taskDateTime,
                        TimeOfDay.fromDateTime(removedTask.taskDateTime)),
                    taskRepeat: removedTask.taskRepeat,
                    title: removedTask.title,
                    user: removedTask.user,
                  )));
                }
              },
              editCallback: (Task task) {
                Navigator.of(appNavigatorContext(context))
                    .push(TransparentRoute(
                  builder: (context) {
                    /*return TaskViewPage(
                      theme: Theme.of(context),
                      task: task,
                    );*/
                    return TaskFormPage(
                      theme: Theme.of(context),
                      selectedDate: task.taskDateTime,
                      task: task,
                      notificationDateTime: task.notificationDateTime,
                    );
                  },
                ));
              },
              selectedDate: selectedDate,
            ),
          ),
        )
        .toList();
  }
}
