import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mood_manager/features/mood_manager/data/models/m_activity_model.dart';
import 'package:mood_manager/features/mood_manager/data/models/t_mood_model.dart';
import 'package:mood_manager/features/mood_manager/presentation/bloc/activity_list_index.dart';
import 'package:mood_manager/features/mood_manager/presentation/bloc/t_mood_index.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/empty_widget.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/activity_choice_chips.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/loading_widget.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/widgets.dart';
import 'package:mood_manager/injection_container.dart';

class ActivityFormPage extends StatefulWidget {
  Map<String, List<MActivityModel>> activityListGroupedByType;
  Map<String, List<MActivityModel>> selectedActivityMap = Map();
  bool isActivitySelected = false;
  TMoodModel tMood;
  Map<String, dynamic> arguments;
  String note;
  GlobalKey<ActivityChoiceChipsState> activityListKey =
      GlobalKey<ActivityChoiceChipsState>();
  @override
  State<ActivityFormPage> createState() => _ActivityFormPageState();

  ActivityFormPage(Object arguments) {
    if (arguments != null) {
      this.arguments = arguments;
    }
  }
}

class _ActivityFormPageState extends State<ActivityFormPage> {
  ActivityListBloc _activityListBloc;
  TMoodBloc _transActionBloc;
  StreamSubscription<TMoodState> subscription;

  _ActivityFormPageState() {
    this._activityListBloc = sl<ActivityListBloc>();
    this._transActionBloc = sl<TMoodBloc>();
  }

  @override
  Widget build(BuildContext context) {
    widget.tMood = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'Tell us about your activity',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
              child: IconButton(
                constraints: BoxConstraints.expand(width: 40),
                icon: Icon(Icons.check),
                onPressed: scrollToBottom,
              ),
            )
          ]),
      body: Column(
        children: <Widget>[
          buildActivityList(context),
        ],
      ),
    );
  }

  BlocProvider<ActivityListBloc> buildActivityList(BuildContext context) {
    return BlocProvider<ActivityListBloc>(
        create: (_) => _activityListBloc,
        child: BlocBuilder<ActivityListBloc, ActivityListState>(
          builder: (context, state) {
            if (state is ActivityListEmpty || state is ActivityListLoading) {
              return LoadingWidget();
            } else if (state is ActivityListLoaded) {
              widget.activityListGroupedByType = state.mActivityListGroupByType;
              return ActivityChoiceChips(
                key: widget.activityListKey,
                groupedActivityList: widget.activityListGroupedByType,
                selectOptions: setActivityList,
                updateNote: (text) {
                  widget.note = text;
                },
                save: saveMood,
              );
            } else if (state is ActivityListError) {
              return MessageDisplay(
                message: state.message,
              );
            }
            return EmptyWidget();
          },
        ));
  }

  scrollToBottom() {
    widget.activityListKey.currentState.scrollToBottom();
  }

  setActivityList(MapEntry<String, List<MActivityModel>> mapEntry) {
    setState(() {
      widget.selectedActivityMap[mapEntry.key] = mapEntry.value;
      widget.isActivitySelected = widget.selectedActivityMap != null &&
          widget.selectedActivityMap.values
              .expand((i) => i)
              .toList()
              .isNotEmpty;
    });
  }

  saveMood() {
    _transActionBloc.add(SaveTMoodEvent(TMoodModel.fromMood(
        widget.arguments['formData'],
        widget.selectedActivityMap.values.expand((item) => item).toList(),
        widget.note)));
  }

  @override
  void initState() {
    super.initState();
    _activityListBloc.add(GetActivityMetaEvent());
    subscription = _transActionBloc.listen((state) {
      if (state is TMoodSaved) {
        //;
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/trans-list', (route) => false,
            arguments: {'lastSaved': state.tMood});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_activityListBloc != null) {
      _activityListBloc.close();
    }
    if (_transActionBloc != null) {
      _transActionBloc.close();
    }
    if (subscription != null) {
      subscription.cancel();
    }
  }
}
