import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_mood.dart';
import 'package:mood_manager/features/mood_manager/presentation/bloc/t_mood_bloc.dart';
import 'package:mood_manager/features/mood_manager/presentation/bloc/t_mood_state.dart';
import 'package:provider/provider.dart';
import 'package:tinycolor/tinycolor.dart';
import 'package:intl/intl.dart';

class TMoodSlidableRow extends StatelessWidget {
  final TMood tMood;
  final SlidableController slidableController;
  final Axis direction;
  final Function deleteCallback;
  final Function editCallback;

  TMoodSlidableRow(
      {@required this.tMood,
      @required this.slidableController,
      @required this.direction,
      @required this.editCallback,
      @required this.deleteCallback});
  @override
  Widget build(BuildContext context) {
    //debugger(when:false);
    return Slidable.builder(
      key: ValueKey(tMood.id),
      controller: slidableController,
      direction: direction,
      dismissal: SlidableDismissal(
        child: SlidableDrawerDismissal(),
        closeOnCanceled: true,
        onWillDismiss: (actionType) {
          return showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Delete'),
                content: Text('Item will be deleted'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  FlatButton(
                    child: Text('Ok'),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              );
            },
          );
        },
        onDismissed: (actionType) {
          deleteCallback();
        },
      ),
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(tMood: tMood),
      actionDelegate: SlideActionBuilderDelegate(
          actionCount: 2,
          builder: (context, index, animation, renderingMode) {
            if (index == 0) {
              return IconSlideAction(
                caption: 'Archive',
                color: renderingMode == SlidableRenderingMode.slide
                    ? Colors.blue.withOpacity(animation.value)
                    : (renderingMode == SlidableRenderingMode.dismiss
                        ? Colors.blue
                        : Colors.green),
                icon: Icons.archive,
                onTap: () async {
                  var state = Slidable.of(context);
                  var dismiss = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Delete'),
                        content: Text('Item will be deleted'),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('Cancel'),
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                          FlatButton(
                            child: Text('Ok'),
                            onPressed: () => Navigator.of(context).pop(true),
                          ),
                        ],
                      );
                    },
                  );
                  if (dismiss) {
                    state.dismiss();
                  }
                },
              );
            } else {
              return IconSlideAction(
                caption: 'Share',
                color: renderingMode == SlidableRenderingMode.slide
                    ? Colors.indigo.withOpacity(animation.value)
                    : Colors.indigo,
                icon: Icons.share,
                onTap: () => {},
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
                onTap: deleteCallback,
              );
            }
          }),
    );
  }
}

class VerticalListItem extends StatefulWidget {
  VerticalListItem({this.tMood});

  final TMood tMood;

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
    textStyle =
        TextStyle(color: TinyColor(widget.tMood.mMood.color).darken(20).color);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () =>
            Slidable.of(context)?.renderingMode == SlidableRenderingMode.none
                ? Slidable.of(context)?.open()
                : Slidable.of(context)?.close(),
        child: Container(
          height: 90,
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[400]))),
          child: ListTile(
            isThreeLine: true,
            leading: CircleAvatar(
              backgroundColor: widget.tMood.mMood.color,
              foregroundColor: Colors.white,
              radius: 30,
            ),
            title: Text(
              widget.tMood.mMood.name.toUpperCase(),
              style: TextStyle(
                  color: TinyColor(widget.tMood.mMood.color).darken(20).color),
            ),
            subtitle: Wrap(
              children: <Widget>[
                Text(widget.tMood.tActivityList
                    .map((e) => e.mActivity.name)
                    .join(' | ')),
                Text(
                  widget.tMood.note ?? '',
                )
              ],
            ),
            trailing: Text(
                DateFormat(DateFormat.HOUR_MINUTE)
                    .format(widget.tMood.logDateTime),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                )),
          ),
        ),
      );
  }
}
