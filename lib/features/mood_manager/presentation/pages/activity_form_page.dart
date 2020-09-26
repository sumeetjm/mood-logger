import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mood_manager/core/constants/app_constants.dart';
import 'package:mood_manager/features/mood_manager/data/models/parse/m_activity_parse.dart';
import 'package:mood_manager/features/mood_manager/data/models/parse/t_activity_parse.dart';
import 'package:mood_manager/features/mood_manager/data/models/parse/t_mood_parse.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_activity.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/m_activity_type.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_mood.dart';
import 'package:mood_manager/features/mood_manager/domain/usecases/get_m_activity_list.dart';
import 'package:mood_manager/features/mood_manager/presentation/bloc/activity_list_index.dart';
import 'package:mood_manager/features/mood_manager/presentation/bloc/t_mood_index.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/activity_choice_chips.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/empty_widget.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/loading_widget.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/message_display.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:provider/provider.dart';

class ActivityFormPage extends StatefulWidget {
  List<MActivityType> activityTypeList;
  Map<String, List<MActivity>> selectedActivityMap = Map();
  bool isActivitySelected = false;
  Map<String, dynamic> arguments;
  String note;
  GlobalKey<ActivityChoiceChipsState> activityListKey =
      GlobalKey<ActivityChoiceChipsState>();
  @override
  State<ActivityFormPage> createState() => _ActivityFormPageState();

  ActivityFormPage({this.arguments});
}

class _ActivityFormPageState extends State<ActivityFormPage> {
  ActivityListBloc _activityListBloc;
  TMoodBloc tMoodBloc;
  StreamSubscription<TMoodState> subscription;

  _ActivityFormPageState() {
    _activityListBloc = sl<ActivityListBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: <Widget>[
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
            } else if (state is ActivityTypeListLoaded) {
              widget.activityTypeList = state.mActivityTypeList;
              return ActivityChoiceChips(
                key: widget.activityListKey,
                activityTypeList: widget.activityTypeList,
                selectOptions: setActivityList,
                updateNote: (text) {
                  widget.note = text;
                },
                save: saveMood,
                maxSelected: 5,
                selected: widget.selectedActivityMap.values
                    .expand((item) => item)
                    .toList(),
                initialValue: widget.selectedActivityMap,
                color: Theme.of(context).primaryColor,
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

  setActivityList(MapEntry<String, List<MActivity>> mapEntry) {
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
    tMoodBloc.add(SaveTMoodEvent(
        TMoodParse.fromMood(
            widget.arguments['formData'],
            widget.selectedActivityMap.values.expand((item) => item).toList(),
            widget.note),
        AppConstants.ACTION['ADD']));
  }

  @override
  void initState() {
    super.initState();
    tMoodBloc = BlocProvider.of<TMoodBloc>(context);
    _activityListBloc.add(GetMActivityTypeListEvent());
    subscription = tMoodBloc.listen((state) {
      if (state is TMoodSaved) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        /* Navigator.of(context).poppushNamedAndRemoveUntil(
            '/trans-list', (route) => false,
            arguments: {'lastSaved': state.tMood});*/
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_activityListBloc != null) {
      _activityListBloc.close();
    }
    if (subscription != null) {
      subscription.cancel();
    }
  }
}
