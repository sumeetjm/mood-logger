import 'package:chips_choice/chips_choice.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
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
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:tinycolor/tinycolor.dart';

// ignore: must_be_immutable
class TaskFormPage extends StatefulWidget {
  DateTime selectedDate;
  DateTime notificationDateTime;
  Task task;
  Duration duration;

  TaskFormPage(
      {Key key, this.selectedDate, this.task, this.notificationDateTime})
      : super(key: key) {
    if (this.selectedDate == null) {
      this.selectedDate = DateTime.now();
      this.notificationDateTime = this.selectedDate;
    }
    if (this.notificationDateTime == null) {
      this.notificationDateTime = this.selectedDate;
    }
    duration = selectedDate.difference(notificationDateTime);
  }
  @override
  _TaskFormPageState createState() => _TaskFormPageState(task);
}

class _TaskFormPageState extends State<TaskFormPage> {
  List<MActivity> activityList = [];
  Color color = Colors.white;
  bool isNotify = true;
  TextEditingController noteTitleController = TextEditingController();
  TextEditingController noteTextController = TextEditingController();
  TaskBloc _taskBloc;
  String notificationType = 'Notification';
  List selectedDays = [];
  TaskRepeat taskRepeat = TaskRepeatParse(
    repeatType: 'Once',
  );

  _TaskFormPageState(Task task) {
    if (task != null) {
      activityList = task.mActivityList;
      color = task.color;
      isNotify = true;
      noteTitleController.text = task.title;
      noteTextController.text = task.note;
      taskRepeat = task.taskRepeat;
    }
  }

  @override
  void initState() {
    super.initState();
    _taskBloc = BlocProvider.of<TaskBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black.withOpacity(0.7),
      body: SingleChildScrollView(
        // physics: NeverScrollableScrollPhysics(),
        child: BlocConsumer(
          cubit: _taskBloc,
          listener: (context, state) {
            if (state is TaskSaved) {
              _taskBloc.add(GetTaskListEvent());
              Navigator.of(context).pop();
            }
            handleLoader(state, context);
          },
          builder: (context, state) => Column(
            children: [
              Container(
                //height: MediaQuery.of(context).size.height - 100,
                padding: EdgeInsets.all(8.0),
                margin: EdgeInsets.fromLTRB(10, 60, 10, 60),
                decoration: BoxDecoration(
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: color,
                      offset: const Offset(
                        5.0,
                        5.0,
                      ),
                      blurRadius: 10.0,
                      spreadRadius: 2.0,
                    ), //BoxShadow
                    BoxShadow(
                      color: color,
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
                          widget.selectedDate = date;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () async {
                              Navigator.of(context).pop();
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
                              Navigator.of(context).push(
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
                        ),
                        IconButton(
                            icon: Icon(Icons.done),
                            onPressed: () async {
                              if (taskRepeat.repeatType == 'Once') {
                                taskRepeat.selectedDateList = [
                                  DateUtil.getDateOnly(widget.selectedDate)
                                ];
                              }
                              _taskBloc.add(
                                SaveTaskEvent(
                                  task: TaskParse(
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
                            }),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.color_lens_outlined),
                          onPressed: () {
                            _openMainColorPicker(context);
                          },
                        ),
                        IconButton(
                          icon: Icon(isNotify
                              ? Icons.notifications_active_outlined
                              : Icons.notifications_off_outlined),
                          onPressed: () {
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
                                        Navigator.of(context).pop();
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
                                color: Theme.of(context).primaryColor),
                            onPressed: () async {
                              var repeat = await showDialog(
                                context: context,
                                builder: (context) {
                                  return TaskRepeatDialog(
                                      taskRepeat,
                                      DateUtil.getDateOnly(
                                          widget.selectedDate));
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
                          controller: noteTextController,
                          minLines: 6,
                          maxLines: 15,
                          autocorrect: false,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Your task here',
                          ),
                        )),
                        ChipsChoice.multiple(
                          value: activityList,
                          options:
                              ChipsChoiceOption.listFrom<MActivity, MActivity>(
                            source: activityList ?? [],
                            value: (i, v) => v,
                            label: (i, v) => v.activityName,
                          ),
                          onChanged: (List<MActivity> value) {},
                          isWrapped: true,
                        ),
                      ],
                    ),
                    if (isNotify)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Notify'),
                          IconButton(
                              icon: Icon(Icons.timer),
                              onPressed: () {
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openMainColorPicker(context) async {
    _openDialog(
        "Main Color picker",
        MaterialColorPicker(
          selectedColor: color,
          allowShades: false,
          circleSize: 30,
          onMainColorChange: (color) =>
              setState(() => this.color = TinyColor(color).lighten(30).color),
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
