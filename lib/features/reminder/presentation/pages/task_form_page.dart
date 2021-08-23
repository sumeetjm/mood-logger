import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mood_manager/core/util/date_util.dart';
import 'package:mood_manager/features/common/domain/entities/base_states.dart';
import 'package:mood_manager/features/common/presentation/pages/activity_selection_page.dart';
import 'package:mood_manager/features/common/presentation/widgets/date_selector.dart';
import 'package:mood_manager/features/common/presentation/widgets/time_picker.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity.dart';
import 'package:mood_manager/features/reminder/data/models/task_parse.dart';
import 'package:mood_manager/features/reminder/data/models/task_repeat_parse.dart';
import 'package:mood_manager/features/reminder/domain/entities/task.dart';
import 'package:mood_manager/features/reminder/domain/entities/task_repeat.dart';
import 'package:mood_manager/features/reminder/presentation/bloc/task_bloc.dart';
import 'package:mood_manager/features/reminder/presentation/widgets/duration_picker.dart';
import 'package:mood_manager/features/reminder/presentation/widgets/task_repeat_dialog.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:tinycolor/tinycolor.dart';
import 'package:mood_manager/home.dart';
import 'package:uuid/uuid.dart';

// ignore: must_be_immutable
class TaskFormPage extends StatefulWidget {
  DateTime selectedDate;
  DateTime notificationDateTime;
  Task task;
  Duration duration = Duration();
  ThemeData theme;

  TaskFormPage({
    Key key,
    this.selectedDate,
    this.task,
    this.notificationDateTime,
    this.theme,
  }) : super(key: key) {
    if (this.task == null) {
      initialize(this.selectedDate);
    }
  }
  @override
  _TaskFormPageState createState() => _TaskFormPageState(task, theme);

  initialize(selectedDate) {
    if (selectedDate == null) {
      this.selectedDate = DateTime.now();
    } else if (task == null) {
      this.selectedDate = DateUtil.combine(selectedDate, TimeOfDay.now());
    } else {
      this.selectedDate = selectedDate;
    }
    if (this.notificationDateTime == null) {
      this.notificationDateTime = this.selectedDate;
    }
    duration = this.selectedDate.difference(notificationDateTime);
  }
}

class _TaskFormPageState extends State<TaskFormPage> {
  List<MActivity> activityList = [];
  Color color;
  int colorPickerValue;
  bool isNotify = true;
  TextEditingController noteTitleController = TextEditingController();
  TextEditingController noteTextController = TextEditingController();
  TaskBloc _taskBloc;
  String notificationType = 'Notification';
  List selectedDays = [];
  TaskRepeat taskRepeat = TaskRepeatParse(
    repeatType: 'Once',
  );
  bool disableDateChange = false;
  Uuid uuid;
  final FocusNode titleFocusNode = FocusNode();
  final FocusNode noteFocusNode = FocusNode();

  _TaskFormPageState(Task task, ThemeData theme) {
    if (task != null) {
      color = [
        ...materialColors
            .map((e) => ColorSwatch(TinyColor(e).lighten(30).color.value, {}))
            .toList(),
        ColorSwatch(TinyColor(theme.primaryColor).lighten(45).color.value, {}),
        ColorSwatch(TinyColor(theme.accentColor).lighten(10).color.value, {}),
      ].singleWhere((element) =>
          element.blue == task.color.blue &&
          element.red == task.color.red &&
          element.green == task.color.green);
      isNotify = true;
      noteTitleController.text = task.title;
      noteTextController.text = task.note;
      taskRepeat = task.taskRepeat;
      activityList = task.mActivityList;
      if (task.id != null &&
          taskRepeat.selectedDateList.any((element) => DateUtil.combine(
                  element, TimeOfDay.fromDateTime(task.taskDateTime))
              .isBefore(DateTime.now()))) {
        disableDateChange = true;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _taskBloc = BlocProvider.of<TaskBloc>(context);
    if (color == null) {
      color = materialColors
          .map((e) => ColorSwatch(TinyColor(e).lighten(30).color.value, {}))
          .first;
    }
    if (widget.task != null) {
      widget.initialize(widget.task.taskDateTime);
    }
    uuid = sl<Uuid>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black.withOpacity(0.7),
      body: SingleChildScrollView(
        // physics: NeverScrollableScrollPhysics(),
        child: BlocConsumer(
          cubit: _taskBloc,
          listener: (context, state) {
            if (state is TaskSaved) {
              _taskBloc.add(GetTaskListEvent());
              Navigator.of(appNavigatorContext(context)).pop();
            }
            handleLoader(state, context);
          },
          builder: (context, state) => Column(
            children: [
              Container(
                //height: MediaQuery.of(context).size.height - 100,
                padding: EdgeInsets.all(8.0),
                margin: EdgeInsets.fromLTRB(20, 60, 20, 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: TinyColor(color).darken(15).color,
                      offset: const Offset(
                        2,
                        2,
                      ),
                      blurRadius: 10.0,
                      spreadRadius: 2.0,
                    ), //BoxShadow
                    BoxShadow(
                      color: TinyColor(color).darken(5).color,
                      offset: const Offset(0.0, 0.0),
                      blurRadius: 0.0,
                      spreadRadius: 0.0,
                    ), //BoxShadow
                  ],
                ),
                child: Column(
                  children: [
                    DateSelector(
                      startDate: DateTime.now(),
                      initialDate: widget.selectedDate,
                      selectDate: (DateTime date) {
                        setState(() {
                          widget.selectedDate = DateUtil.combine(date,
                              TimeOfDay.fromDateTime(widget.selectedDate));
                        });
                      },
                      enabled: !disableDateChange,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () async {
                              Navigator.of(appNavigatorContext(context)).pop();
                            }),
                        IconButton(
                            iconSize: 15,
                            icon: Row(
                              children: [
                                ImageIcon(AssetImage('assets/activity.png')),
                                Text(
                                  ' (${activityList.length})',
                                  style: TextStyle(fontSize: 10.5),
                                )
                              ],
                            ),
                            onPressed: () {
                              hideKeyboard();
                              Navigator.of(appNavigatorContext(context)).push(
                                MaterialPageRoute(
                                  builder: (context) => ActivitySelectionPage(
                                    selectedActivityList: activityList,
                                    onChange: (value) {
                                      setState(() {
                                        activityList = value;
                                      });
                                    },
                                  ),
                                ),
                              );
                            }),
                        TimePicker(
                          selectTime: (value) {
                            setState(() {
                              widget.selectedDate = DateTimeField.combine(
                                  widget.selectedDate, value);
                              widget.notificationDateTime =
                                  widget.selectedDate.subtract(widget.duration);
                            });
                          },
                          selectedTime:
                              TimeOfDay.fromDateTime(widget.selectedDate),
                          textStyle: TextStyle(fontSize: 15),
                          enabled: !disableDateChange,
                        ),
                        IconButton(
                            icon: Icon(Icons.done),
                            onPressed: () async {
                              hideKeyboard();
                              if (taskRepeat.repeatType == 'Once') {
                                taskRepeat.selectedDateList = [
                                  DateUtil.getDateOnly(widget.selectedDate)
                                ];
                              }
                              if (noteTitleController.text == null ||
                                  noteTitleController.text.trim().isEmpty) {
                                Fluttertoast.showToast(
                                    gravity: ToastGravity.TOP,
                                    msg: 'Title is mandatory',
                                    backgroundColor: Colors.red);
                              } else {
                                _taskBloc.add(
                                  SaveTaskEvent(
                                    task: TaskParse(
                                      colorPickerValue: color.value,
                                      memoryMapByDate:
                                          widget.task?.memoryMapByDate ?? {},
                                      id: widget.task?.id,
                                      color: color,
                                      mActivityList: activityList,
                                      title: noteTitleController.text,
                                      note: noteTextController.text,
                                      taskDateTime: widget.selectedDate,
                                      user: await ParseUser.currentUser(),
                                      notificationDateTime:
                                          widget.notificationDateTime,
                                      taskRepeat: taskRepeat,
                                    ),
                                    cancelNotificationId: widget
                                        .task
                                        ?.notificationDateTime
                                        ?.millisecondsSinceEpoch,
                                  ),
                                );
                              }
                            }),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.color_lens_outlined),
                          onPressed: () {
                            hideKeyboard();
                            _openMainColorPicker(context);
                          },
                        ),
                        IconButton(
                          icon: Icon(isNotify
                              ? Icons.notifications_active_outlined
                              : Icons.notifications_off_outlined),
                          onPressed: () {
                            hideKeyboard();
                            _openDialog(
                                'title',
                                Column(
                                  children: [
                                    ListTile(
                                      selected: notificationType == null,
                                      title: Text('None'),
                                      selectedTileColor: TinyColor(Colors.white)
                                          .darken(10)
                                          .color,
                                      onTap: () {
                                        setState(() {
                                          notificationType = null;
                                          isNotify = false;
                                        });
                                        Navigator.of(
                                                appNavigatorContext(context))
                                            .pop();
                                      },
                                    ),
                                    ListTile(
                                      selected:
                                          notificationType == 'Notification',
                                      title: Text('Notification'),
                                      selectedTileColor: TinyColor(Colors.white)
                                          .darken(10)
                                          .color,
                                      onTap: () {
                                        setState(() {
                                          notificationType = 'Notification';
                                          isNotify = true;
                                        });
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                ),
                                context);
                          },
                        ),
                        IconButton(
                            icon: Icon(
                                taskRepeat?.repeatType == 'Once'
                                    ? Icons.repeat_outlined
                                    : Icons.repeat_outlined,
                                color: widget.theme.primaryColor),
                            onPressed: () async {
                              hideKeyboard();
                              var repeat = await showDialog(
                                context: context,
                                builder: (context) {
                                  return TaskRepeatDialog(
                                      taskRepeat,
                                      DateUtil.getDateOnly(widget.selectedDate),
                                      !disableDateChange);
                                },
                              );
                              if (repeat != null) {
                                setState(() {
                                  taskRepeat = repeat;
                                });
                              }
                            }),
                      ],
                    ),
                    ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        Container(
                          child: TextField(
                            focusNode: titleFocusNode,
                            maxLength: 100,
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            style: TextStyle(fontSize: 20),
                            controller: noteTitleController,
                            minLines: 1,
                            maxLines: 1,
                            autocorrect: false,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Title',
                            ),
                          ),
                        ),
                        Container(
                            child: TextField(
                          focusNode: noteFocusNode,
                          controller: noteTextController,
                          minLines: 6,
                          maxLines: 15,
                          autocorrect: false,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Your task here',
                          ),
                        )),
                        Row(
                            children: activityList
                                .map((e) => Padding(
                                      padding: EdgeInsets.all(2),
                                      child: Hero(
                                        tag: e.id +
                                            e.hashCode.toString() +
                                            (widget.task?.id ?? ''),
                                        child: Chip(
                                          backgroundColor: TinyColor(color)
                                              .lighten(20)
                                              .color,
                                          label: Text(e.activityName),
                                          padding: EdgeInsets.all(2),
                                        ),
                                      ),
                                    ))
                                .toList()),
                      ],
                    ),
                    if (isNotify)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Notify'),
                          IconButton(
                              icon: Icon(Icons.timer),
                              onPressed: () async {
                                hideKeyboard();
                                await Future.delayed(
                                    Duration(milliseconds: 500));
                                _openDialog(
                                    'title',
                                    DurationPicker(
                                      submitCallback: (duration) {
                                        setState(() {
                                          widget.duration = duration;
                                          widget.notificationDateTime = widget
                                              .selectedDate
                                              .subtract(duration);
                                        });
                                      },
                                      duration: widget.duration,
                                    ),
                                    context);
                              }),
                          Text(
                              ' ${widget.duration.inHours % 24} h ${widget.duration.inMinutes % 60} m ${widget.duration.inSeconds % 60} s before'),
                        ],
                      ),
                    if (disableDateChange)
                      Text(
                          'Task date and time change not allowed if it is before current date and time')
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  hideKeyboard() {
    titleFocusNode.unfocus();
    noteFocusNode.unfocus();
  }

  void _openMainColorPicker(context) async {
    _openDialog(
        "Main Color picker",
        MaterialColorPicker(
          colors: [
            ...materialColors
                .map((e) =>
                    ColorSwatch(TinyColor(e).lighten(30).color.value, {}))
                .toList(),
            ColorSwatch(
                TinyColor(widget.theme.primaryColor).lighten(45).color.value,
                {}),
            ColorSwatch(
                TinyColor(widget.theme.accentColor).lighten(10).color.value,
                {}),
          ],
          iconSelected: Icons.done,
          selectedColor: color,
          allowShades: false,
          circleSize: 30,
          onMainColorChange: (color) => setState(() {
            this.color = color;
            this.colorPickerValue = color.value;
          }),
        ),
        context);
  }

  void _openDialog(String title, Widget content, context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        child: content,
        height: 180,
      ),
    );
  }
}
