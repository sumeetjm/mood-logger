import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mood_manager/core/constants/app_constants.dart';
import 'package:mood_manager/core/util/date_util.dart';
import 'package:mood_manager/features/memory/data/models/memory_parse.dart';
import 'package:mood_manager/features/reminder/data/datasources/task_notification_remote_data_source.dart';
import 'package:mood_manager/features/reminder/data/models/task_notification_mapping_parse.dart';
import 'package:mood_manager/features/reminder/data/models/task_repeat_parse.dart';
import 'package:mood_manager/features/reminder/domain/entities/task_notification_mapping.dart';
import 'package:mood_manager/features/reminder/domain/entities/task_repeat.dart';
import 'package:mood_manager/features/reminder/presentation/bloc/task_bloc.dart';
import 'package:mood_manager/features/reminder/presentation/widgets/duration_picker.dart';
import 'package:mood_manager/home.dart';
import 'package:tinycolor/tinycolor.dart';
import 'package:intl/intl.dart';

import '../../../../injection_container.dart';

// ignore: must_be_immutable
class TaskViewPage extends StatefulWidget {
  List<TaskNotificationMapping> taskNotificationMappingList;
  ThemeData theme;

  TaskViewPage({Key key, this.theme, this.taskNotificationMappingList})
      : super(key: key);
  @override
  _TaskViewPageState createState() => _TaskViewPageState();
}

class _TaskViewPageState extends State<TaskViewPage> {
  TaskBloc _taskBloc;
  Duration notifyAfterDuration = Duration();
  DateTime afterNotificationDateTime;
  TaskNotificationRemoteDataSource taskNotificationDataSource =
      sl<TaskNotificationRemoteDataSource>();

  @override
  void initState() {
    super.initState();
    _taskBloc = BlocProvider.of<TaskBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black.withOpacity(0.7),
      body: Container(
        margin: EdgeInsets.fromLTRB(0, 60, 0, 0),
        child: ListView.separated(
          separatorBuilder: (context, index) => SizedBox(
            height: 20,
          ),
          itemCount: widget.taskNotificationMappingList.length,
          itemBuilder: (context, index) {
            final taskNotificationMapping =
                widget.taskNotificationMappingList[index];
            var taskDateTime;
            if (taskNotificationMapping.isAfterTask) {
              taskDateTime = taskNotificationMapping
                  .task.taskRepeat.selectedDateList
                  .map((e) => DateUtil.combine(
                      e,
                      TimeOfDay.fromDateTime(
                          taskNotificationMapping.task.taskDateTime)))
                  .lastWhere((element) =>
                      element.isBefore(taskNotificationMapping.notifyDateTime));
            } else {
              taskDateTime = taskNotificationMapping
                  .task.taskRepeat.selectedDateList
                  .map((e) => DateUtil.combine(
                      e,
                      TimeOfDay.fromDateTime(
                          taskNotificationMapping.task.taskDateTime)))
                  .firstWhere((element) =>
                      element.isAfter(taskNotificationMapping.notifyDateTime) ||
                      element.isAtSameMomentAs(
                          taskNotificationMapping.notifyDateTime));
            }
            return Dismissible(
              background: Container(
                color: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 20),
                alignment: AlignmentDirectional.centerStart,
                child: Icon(
                  Icons.done,
                  color: Colors.white,
                ),
              ),
              secondaryBackground: Container(
                color: Colors.transparent,
                padding: EdgeInsets.symmetric(horizontal: 20),
                alignment: AlignmentDirectional.centerEnd,
              ),
              onDismissed: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  final taskDate = DateUtil.getDateOnly(taskDateTime);
                  await TaskRepeatParse(
                    id: taskNotificationMapping.task.taskRepeat.id,
                    markedDoneDateList: [
                      ...taskNotificationMapping
                          .task.taskRepeat.markedDoneDateList,
                      taskDate
                    ],
                    repeatType:
                        taskNotificationMapping.task.taskRepeat.repeatType,
                    selectedDateList: taskNotificationMapping
                        .task.taskRepeat.selectedDateList,
                    validUpto:
                        taskNotificationMapping.task.taskRepeat.validUpto,
                  ).toParse().save();
                  _taskBloc.add(GetTaskListEvent());
                }
                widget.taskNotificationMappingList.removeAt(index);
                if (widget.taskNotificationMappingList.isEmpty) {
                  Navigator.of(appNavigatorContext(context)).pop();
                } else {
                  setState(() {});
                }
              },
              key: ValueKey(taskNotificationMapping.id),
              child: Container(
                margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Container(
                  padding: EdgeInsets.fromLTRB(8, 30, 8, 0),
                  //height: MediaQuery.of(context).size.height - 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: taskNotificationMapping.task.color,
                    boxShadow: [
                      BoxShadow(
                        color: TinyColor(taskNotificationMapping.task.color)
                            .darken(15)
                            .color,
                        offset: const Offset(
                          2,
                          2,
                        ),
                        blurRadius: 10.0,
                        spreadRadius: 2.0,
                      ), //BoxShadow
                      BoxShadow(
                        color: TinyColor(taskNotificationMapping.task.color)
                            .darken(5)
                            .color,
                        offset: const Offset(0.0, 0.0),
                        blurRadius: 0.0,
                        spreadRadius: 0.0,
                      ), //BoxShadow
                    ],
                  ),
                  child: ListView(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: [
                      Center(
                          child: Container(
                              height: 30,
                              child: Text(
                                DateFormat(AppConstants.TASK_VIEW_DATE_FORMAT)
                                    .format(taskDateTime),
                                style: TextStyle(
                                    color: Colors.grey[800],
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic),
                              ))),
                      ListTile(
                          isThreeLine: true,
                          //tileColor: TinyColor(widget.task.color).lighten(25).color,
                          title: Text(
                            (taskNotificationMapping.task.title ?? ''),
                            style: TextStyle(
                                color: TinyColor(
                                        taskNotificationMapping.task.color)
                                    .darken(50)
                                    .color),
                          ),
                          subtitle: Column(children: [
                            Text(taskNotificationMapping.task.note),
                            Row(
                                children:
                                    taskNotificationMapping.task.mActivityList
                                        .map((e) => Padding(
                                              padding: EdgeInsets.all(2),
                                              child: Hero(
                                                tag: e.id +
                                                    e.hashCode.toString() +
                                                    (taskNotificationMapping
                                                            .task?.id ??
                                                        ''),
                                                child: Chip(
                                                  backgroundColor: TinyColor(
                                                          taskNotificationMapping
                                                              .task.color)
                                                      .lighten(20)
                                                      .color,
                                                  label: Text(e.activityName),
                                                  padding: EdgeInsets.all(2),
                                                ),
                                              ),
                                            ))
                                        .toList()),
                          ])),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            child: Row(
                              children: [
                                Icon(Icons.add_photo_alternate,
                                    color: Colors.black),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Add Memory',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                            onPressed: () async {
                              final savedMemory = await Navigator.of(
                                      appNavigatorContext(context))
                                  .pushNamed('/memory/add', arguments: {
                                'memory': MemoryParse.fromTask(
                                    taskNotificationMapping.task,
                                    taskNotificationMapping.task.taskDateTime,
                                    taskNotificationMapping.task.mActivityList),
                                'task': taskNotificationMapping.task
                              });
                              if (savedMemory != null) {
                                Navigator.of(appNavigatorContext(context)).pop();
                                _taskBloc.add(GetTaskListEvent());
                              }
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Notify after'),
                          IconButton(
                              icon: Icon(Icons.timer),
                              onPressed: () {
                                _openDialog(
                                    'title',
                                    DurationPicker(
                                      submitCallback: (duration) {
                                        setState(() {
                                          notifyAfterDuration = duration;
                                          afterNotificationDateTime =
                                              DateTime.now().add(duration);
                                          taskNotificationDataSource
                                              .scheduleTimedTaskNotification(
                                                  TaskNotificationMappingParse(
                                                      localNotificationId:
                                                          afterNotificationDateTime
                                                                  .millisecondsSinceEpoch ~/
                                                              1000,
                                                      notifyDateTime:
                                                          afterNotificationDateTime,
                                                      task:
                                                          taskNotificationMapping
                                                              .task,
                                                      isAfterTask: true));
                                          Navigator.of(
                                                  appNavigatorContext(context))
                                              .pop();
                                        });
                                      },
                                      duration: notifyAfterDuration,
                                    ),
                                    context);
                              }),
                          Text(
                              ' ${notifyAfterDuration.inHours % 24} h ${notifyAfterDuration.inMinutes % 60} m ${notifyAfterDuration.inSeconds % 60} s'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
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
