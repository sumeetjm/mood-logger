import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mood_manager/core/util/date_util.dart';
import 'package:mood_manager/features/memory/data/models/memory_parse.dart';
import 'package:mood_manager/features/memory/presentation/pages/memory_list_page.dart';
import 'package:mood_manager/features/reminder/domain/entities/task.dart';
import 'package:mood_manager/features/reminder/presentation/bloc/task_bloc.dart';
import 'package:tinycolor/tinycolor.dart';
import 'package:intl/intl.dart';

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
        dismissThresholds: {SlideActionType.primary: 1},
        child: SlidableDrawerDismissal(),
        closeOnCanceled: true,
        onWillDismiss: (actionType) {
          return showDeleteAlert(context);
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
        editCallback: editCallback,
      ),
      actionDelegate: DateUtil.combine(
                  selectedDate, TimeOfDay.fromDateTime(task.taskDateTime))
              .isAfter(DateTime.now())
          ? null
          : SlideActionBuilderDelegate(
              actionCount: 1,
              builder: (context, index, animation, renderingMode) {
                final memory =
                    task.memoryMapByDate[DateUtil.getDateOnly(selectedDate)];
                if (memory != null) {
                  return IconSlideAction(
                    caption: 'View Memory',
                    color: renderingMode == SlidableRenderingMode.slide
                        ? Colors.indigo.withOpacity(animation.value)
                        : Colors.indigo,
                    icon: Icons.photo_library,
                    onTap: () => {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MemoryListPage(
                          arguments: {
                            'memoryList': [memory]
                          },
                        ),
                      ))
                    },
                  );
                }
                return IconSlideAction(
                  caption: 'Memory',
                  color: renderingMode == SlidableRenderingMode.slide
                      ? Colors.indigo.withOpacity(animation.value)
                      : Colors.indigo,
                  icon: Icons.add_photo_alternate,
                  onTap: () async {
                    final savedMemory = await Navigator.of(context)
                        .pushNamed('/memory/add', arguments: {
                      'memory': MemoryParse.fromTask(task, selectedDate),
                      'task': task
                    });
                    if (savedMemory != null) {
                      _taskBloc.add(GetTaskListEvent());
                    }
                  },
                );
              }),
      secondaryActionDelegate: SlideActionBuilderDelegate(
          actionCount: 2,
          builder: (context, index, animation, renderingMode) {
            if (index == 0) {
              return IconSlideAction(
                caption: 'Edit',
                color: renderingMode == SlidableRenderingMode.slide
                    ? Colors.grey.shade200.withOpacity(animation.value)
                    : Colors.grey.shade200,
                icon: Icons.edit,
                onTap: () {
                  editCallback();
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
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(true),
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
  });

  final Task task;
  final Function editCallback;
  final Function deleteCallback;

  @override
  State<StatefulWidget> createState() => VerticalListItemState();
}

class VerticalListItemState extends State<VerticalListItem>
    with SingleTickerProviderStateMixin {
  double opacity = 0;
  TextStyle textStyle;
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
      child: Stack(
        children: [
          Container(
            height: 90,
            decoration: BoxDecoration(
                color: TinyColor(widget.task.color).lighten(0).color,
                border: Border(bottom: BorderSide(color: Colors.grey[400]))),
            child: ClipRect(
              child: ListTile(
                isThreeLine: true,
                //tileColor: TinyColor(widget.task.color).lighten(25).color,
                title: Text(
                  (widget.task.title ?? ''),
                  style: TextStyle(
                      color: TinyColor(widget.task.color).darken(50).color),
                ),
                subtitle: Text(
                  widget.task.mActivityList
                          .map((e) => e.activityName)
                          .join(' | ') +
                      '\n' +
                      (widget.task.note ?? ''),
                  style: TextStyle(fontSize: 12.5),
                ),
                trailing: Text(
                    DateFormat(DateFormat.HOUR_MINUTE)
                        .format(widget.task.taskDateTime),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    )),
              ),
            ),
          ),
          Positioned(
            child: Container(
              color: TinyColor(widget.task.color).darken(50).color,
              width: 5,
              height: 90,
              /*child: Container(
                width: 10,
              ),*/
            ),
            left: 0,
          ),
          Positioned(
            child: PopupMenuButton(
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    child: Text('Edit'),
                    value: widget.editCallback,
                  ),
                  PopupMenuItem(
                    child: Text('Delete'),
                    value: widget.deleteCallback,
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
    );
  }
}
