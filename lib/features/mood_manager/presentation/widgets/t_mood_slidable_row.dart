import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mood_manager/features/mood_manager/data/models/m_mood_model.dart';
import 'package:mood_manager/features/mood_manager/data/streams/stream_service.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_activity.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_mood.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_activity.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_mood.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:provider/provider.dart';
import 'package:tinycolor/tinycolor.dart';
import 'package:intl/intl.dart';

class TMoodSlidableRow extends StatelessWidget {
  // final TMoodModel tMood;
  final SlidableController slidableController;
  final Axis direction;
  final Function deleteCallback;
  final Function editCallback;

  TMoodSlidableRow(
      {/*@required this.tMood,*/
      @required this.slidableController,
      @required this.direction,
      @required this.editCallback,
      @required this.deleteCallback});
  @override
  Widget build(BuildContext context) {
    final TMood tMood = Provider.of<TMood>(context);
    return Slidable.builder(
      key: ValueKey(tMood?.transMoodId),
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
      child: Column(
        children: <Widget>[
          if (tMood != null) VerticalListItem(tMood),
        ],
      ),
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
                onTap: editCallback,
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

class VerticalListItem extends StatelessWidget {
  VerticalListItem(this.item);
  final TMood item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Slidable.of(context)?.renderingMode == SlidableRenderingMode.none
              ? Slidable.of(context)?.open()
              : Slidable.of(context)?.close(),
      child: FutureBuilder<MMood>(
        initialData: MMoodModel.initial(),
        future: sl<Firestore>()
            .collection('mMood')
            .document(item.mMood.id)
            .snapshots()
            .map((e) => MMoodModel.fromFirestore(e))
            .first,
        builder: (context, snapshot) {
          return Container(
            height: 90,
            //color: Colors.white,
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[400]))),
            child: ListTile(
              isThreeLine: true,
              leading: CircleAvatar(
                backgroundColor: snapshot.data.color,
                foregroundColor: Colors.white,
                radius: 30,
              ),
              title: Text(
                snapshot.data.name.toUpperCase(),
                style: TextStyle(
                    color: TinyColor(snapshot.data.color).darken(20).color),
              ),
              subtitle: Wrap(
                children: <Widget>[
                  StreamBuilder<List<TActivity>>(
                    initialData: [],
                    stream: sl<StreamService>().tActivityList(item),
                    builder: (context, snapshot) =>
                        StreamBuilder<List<MActivity>>(
                            initialData: [],
                            stream: sl<StreamService>()
                                .mActivityList(snapshot.data),
                            builder: (context, snapshot) {
                              return Text(
                                snapshot.data.map((e) => e.name).join(" | "),
                              );
                            }),
                  ),
                  Text(
                    item.note ?? '',
                  )
                ],
              ),
              trailing: Text(
                  DateFormat(DateFormat.HOUR_MINUTE).format(item.logDateTime),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  )),
            ),
          );
        },
      ),
    );
  }
}
