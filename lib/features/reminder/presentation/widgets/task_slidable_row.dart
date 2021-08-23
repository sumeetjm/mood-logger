import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mood_manager/core/util/date_util.dart';
import 'package:mood_manager/features/memory/data/models/memory_parse.dart';
import 'package:mood_manager/features/memory/presentation/pages/memory_list_page.dart';
import 'package:mood_manager/features/reminder/data/datasources/task_remote_data_source.dart';
import 'package:mood_manager/features/reminder/data/models/task_parse.dart';
import 'package:mood_manager/features/reminder/domain/entities/task.dart';
import 'package:mood_manager/features/reminder/presentation/bloc/task_bloc.dart';
import 'package:tinycolor/tinycolor.dart';
import 'package:intl/intl.dart';

import '../../../../home.dart';
import '../../../../injection_container.dart';

hideMemoryOperations(task, selectedDate) {
  return DateUtil.combine(
          selectedDate, TimeOfDay.fromDateTime(task.taskDateTime))
      .isAfter(DateTime.now());
}

// ignore: must_be_immutable
class TaskSlidableRow extends StatelessWidget {
  final Task task;
  final SlidableController slidableController;
  final Axis direction;
  final Function deleteCallback;
  final Function editCallback;
  final DateTime selectedDate;
  bool isAllDates = false;

  TaskSlidableRow({
    @required this.task,
    @required this.slidableController,
    @required this.direction,
    @required this.editCallback,
    @required this.deleteCallback,
    @required this.selectedDate,
  });
  @override
  Widget build(BuildContext context) {
    final TaskBloc _taskBloc = BlocProvider.of<TaskBloc>(context);
    return Slidable.builder(
      key: ValueKey(task.id),
      controller: slidableController,
      direction: direction,
      dismissal: SlidableDismissal(
        //dismissThresholds: {SlideActionType.primary: 1},
        child: SlidableDrawerDismissal(),
        closeOnCanceled: true,
        onWillDismiss: (actionType) async {
          if (actionType == SlideActionType.primary) {
            if (hideMemoryOperations(task, selectedDate)) {
              editCallback(TaskParse.copy(task));
              return false;
            } else {
              final memory =
                  task.memoryMapByDate[DateUtil.getDateOnly(selectedDate)];
              if (memory == null) {
                final savedMemory =
                    await Navigator.of(appNavigatorContext(context))
                        .pushNamed('/memory/add', arguments: {
                  'memory': MemoryParse.fromTask(
                      task, task.taskDateTime, task.mActivityList),
                  'task': task
                });
                if (savedMemory != null) {
                  _taskBloc.add(GetTaskListEvent());
                }
                return false;
              } else {
                await Navigator.of(appNavigatorContext(context))
                    .push(MaterialPageRoute(
                  builder: (context) => MemoryListPage(
                    showMenuButton: false,
                    arguments: {
                      'memoryId': task
                          .memoryMapByDate[DateUtil.getDateOnly(selectedDate)]
                          .id
                    },
                  ),
                ));
                return false;
              }
            }
          } else {
            return showDeleteAlert(context);
          }
        },
        onDismissed: (
          actionType,
        ) {
          deleteCallback(isAllDates);
        },
      ),
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(
        task: task,
        deleteCallback: () async {
          final bool isDelete = await showDeleteAlert(context);
          if (isDelete != null && isDelete) {
            deleteCallback(isAllDates);
          }
        },
        editCallback: (task) => editCallback(task),
        addMemoryCallback: () async {
          final savedMemory = await Navigator.of(appNavigatorContext(context))
              .pushNamed('/memory/add', arguments: {
            'memory': MemoryParse.fromTask(
                task, task.taskDateTime, task.mActivityList),
            'task': task
          });
          if (savedMemory != null) {
            _taskBloc.add(GetTaskListEvent());
          }
        },
        viewMemoryCallback: () => {
          Navigator.of(appNavigatorContext(context)).push(MaterialPageRoute(
            builder: (context) => MemoryListPage(
              showMenuButton: false,
              arguments: {
                'memoryId':
                    task.memoryMapByDate[DateUtil.getDateOnly(selectedDate)].id
              },
            ),
          ))
        },
        selectedDate: selectedDate,
      ),
      actionDelegate: SlideActionBuilderDelegate(
          actionCount: hideMemoryOperations(task, selectedDate) ? 1 : 2,
          builder: (context, index, animation, renderingMode) {
            if (index == 0 && !hideMemoryOperations(task, selectedDate)) {
              final memory =
                  task.memoryMapByDate[DateUtil.getDateOnly(selectedDate)];
              if (memory != null) {
                return IconSlideAction(
                  caption: 'View Memory',
                  color: renderingMode == SlidableRenderingMode.slide
                      ? Colors.green.withOpacity(animation.value)
                      : Colors.green,
                  icon: Icons.photo_library,
                  onTap: () => {
                    Navigator.of(appNavigatorContext(context))
                        .push(MaterialPageRoute(
                      builder: (context) => MemoryListPage(
                        showMenuButton: false,
                        arguments: {'memoryId': memory.id},
                      ),
                    ))
                  },
                );
              }
              return IconSlideAction(
                caption: 'Memory',
                color: renderingMode == SlidableRenderingMode.slide
                    ? Colors.green.withOpacity(animation.value)
                    : Colors.green,
                icon: Icons.add_photo_alternate,
                onTap: () async {
                  final savedMemory =
                      await Navigator.of(appNavigatorContext(context))
                          .pushNamed('/memory/add', arguments: {
                    'memory': MemoryParse.fromTask(
                        task, task.taskDateTime, task.mActivityList),
                    'task': task
                  });
                  if (savedMemory != null) {
                    _taskBloc.add(GetTaskListEvent());
                  }
                },
              );
            } else {
              return IconSlideAction(
                caption: 'Copy to New',
                color: renderingMode == SlidableRenderingMode.slide
                    ? Colors.indigo.withOpacity(animation.value)
                    : Colors.indigo,
                icon: Icons.copy,
                onTap: () {
                  editCallback(TaskParse.copy(task));
                  Slidable.of(context).close();
                },
                closeOnTap: false,
              );
            }
          }),
      secondaryActionDelegate: SlideActionBuilderDelegate(
          actionCount: 2,
          builder: (context, index, animation, renderingMode) {
            if (index == 0) {
              return IconSlideAction(
                caption: 'Edit',
                color: renderingMode == SlidableRenderingMode.slide
                    ? Colors.blueGrey.withOpacity(animation.value)
                    : Colors.blueGrey,
                icon: Icons.edit,
                onTap: () {
                  editCallback(task);
                  Slidable.of(context).close();
                },
                closeOnTap: false,
              );
            } else {
              return IconSlideAction(
                caption: 'Delete',
                color: renderingMode == SlidableRenderingMode.slide
                    ? Colors.red.withOpacity(animation.value)
                    : Colors.red,
                icon: Icons.delete,
                onTap: () async {
                  final bool isDelete = await showDeleteAlert(context);
                  if (isDelete != null && isDelete) {
                    deleteCallback(isAllDates);
                  }
                },
              );
            }
          }),
    );
  }

  Future<bool> showDeleteAlert(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            content: ListView(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                ListTile(
                  title: Text('Delete'),
                  subtitle: Text('Item will be deleted'),
                ),
                CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  value: isAllDates,
                  onChanged: (value) {
                    setState(() {
                      isAllDates = value;
                    });
                  },
                  title: Text('All dates'),
                )
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () =>
                    Navigator.of(appNavigatorContext(context)).pop(false),
              ),
              TextButton(
                child: Text('Ok'),
                onPressed: () =>
                    Navigator.of(appNavigatorContext(context)).pop(true),
              ),
            ],
          ),
        );
      },
    );
  }
}

class VerticalListItem extends StatefulWidget {
  VerticalListItem({
    this.task,
    this.editCallback,
    this.deleteCallback,
    this.addMemoryCallback,
    this.viewMemoryCallback,
    this.selectedDate,
  });

  final Task task;
  final Function editCallback;
  final Function deleteCallback;
  final Function addMemoryCallback;
  final Function viewMemoryCallback;
  final DateTime selectedDate;

  @override
  State<StatefulWidget> createState() => VerticalListItemState();
}

class VerticalListItemState extends State<VerticalListItem>
    with SingleTickerProviderStateMixin {
  double opacity = 0;
  TextStyle textStyle;
  TaskRemoteDataSource taskRemoteDataSource = sl<TaskRemoteDataSource>();
  @override
  void initState() {
    super.initState();
    textStyle = TextStyle(color: TinyColor(widget.task.color).darken(20).color);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Slidable.of(context)?.renderingMode == SlidableRenderingMode.none
              ? Slidable.of(context)?.open()
              : Slidable.of(context)?.close(),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Stack(
          children: [
            Container(
              //height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: TinyColor(widget.task.color).lighten(0).color,
                border: Border.all(
                    style: BorderStyle.solid,
                    width: 1,
                    color: TinyColor(widget.task.color).darken(15).color),
                boxShadow: [
                  BoxShadow(
                    color: TinyColor(widget.task.color).darken(15).color,
                    offset: const Offset(
                      1,
                      1,
                    ),
                    blurRadius: 1.0,
                    spreadRadius: 1,
                  ), //BoxShadow
                  BoxShadow(
                    color: TinyColor(widget.task.color).darken(5).color,
                    offset: const Offset(0.0, 0.0),
                    blurRadius: 1,
                    spreadRadius: 1,
                  ), //BoxShadow
                ],
              ),
              child: ClipRect(
                child: ListTile(
                  isThreeLine: true,
                  //tileColor: TinyColor(widget.task.color).lighten(25).color,
                  title: Text(
                    (widget.task.title ?? ''),
                    style: TextStyle(
                        color: TinyColor(widget.task.color).darken(50).color),
                  ),
                  subtitle: Column(
                    children: [
                      Row(
                          children: widget.task.mActivityList
                              .map((e) => Flexible(
                                    fit: FlexFit.loose,
                                    child: Padding(
                                      padding: EdgeInsets.all(2),
                                      child: Hero(
                                        tag: e.id +
                                            e.hashCode.toString() +
                                            (widget.task?.id ?? ''),
                                        child: Chip(
                                          backgroundColor:
                                              TinyColor(widget.task.color)
                                                  .lighten(20)
                                                  .color,
                                          label: Text(e.activityName),
                                          padding: EdgeInsets.all(2),
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList()),
                      Row(children: [
                        Flexible(
                          child: Text(
                            widget.task.note,
                            overflow: TextOverflow.clip,
                            maxLines: 3,
                          ),
                        ),
                      ]),
                    ],
                  ),
                  trailing: Column(
                    children: [
                      Text(
                          DateFormat(DateFormat.HOUR_MINUTE)
                              .format(widget.task.taskDateTime),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      if (!widget.task.taskRepeat.markedDoneDateList
                          .contains(DateUtil.getDateOnly(widget.selectedDate)))
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              widget.task.taskRepeat.markedDoneDateList = [
                                ...widget.task.taskRepeat.markedDoneDateList,
                                DateUtil.getDateOnly(widget.selectedDate)
                              ];
                            });
                            taskRemoteDataSource.saveTask(widget.task);
                          },
                          child: Icon(Icons.check_circle_outline_rounded,
                              color: TinyColor(widget.task.color)
                                  .darken(50)
                                  .color),
                        ),
                      if (widget.task.taskRepeat.markedDoneDateList
                          .contains(DateUtil.getDateOnly(widget.selectedDate)))
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              widget.task.taskRepeat.markedDoneDateList.remove(
                                  DateUtil.getDateOnly(widget.selectedDate));
                            });
                            taskRemoteDataSource.saveTask(widget.task);
                          },
                          child: Icon(Icons.check_circle_rounded,
                              color: TinyColor(widget.task.color)
                                  .darken(50)
                                  .color),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              child: PopupMenuButton(
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      child: Text('Edit'),
                      value: () => widget.editCallback(widget.task),
                    ),
                    PopupMenuItem(
                      child: Text('Delete'),
                      value: widget.deleteCallback,
                    ),
                    PopupMenuItem(
                      child: Text('Copy to New'),
                      value: () {
                        widget.editCallback(TaskParse.copy(widget.task));
                        Slidable.of(context).close();
                      },
                    ),
                    if (!hideMemoryOperations(
                            widget.task, widget.selectedDate) &&
                        widget.task.memoryMapByDate[
                                DateUtil.getDateOnly(widget.selectedDate)] ==
                            null)
                      PopupMenuItem(
                        child: Text('Add Memory'),
                        value: widget.addMemoryCallback,
                      ),
                    if (!hideMemoryOperations(
                            widget.task, widget.selectedDate) &&
                        widget.task.memoryMapByDate[
                                DateUtil.getDateOnly(widget.selectedDate)] !=
                            null)
                      PopupMenuItem(
                        child: Text('View Memory'),
                        value: widget.viewMemoryCallback,
                      ),
                  ];
                },
                child: Icon(Icons.more_vert),
                onSelected: (fn) {
                  fn();
                },
              ),
              right: 0,
              bottom: 5,
            )
          ],
        ),
      ),
    );
  }
}
