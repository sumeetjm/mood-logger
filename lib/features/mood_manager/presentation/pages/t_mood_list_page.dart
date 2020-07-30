import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mood_manager/core/util/resource_util.dart';
import 'package:mood_manager/features/auth/presentation/bloc/authentication_bloc.dart';
import 'package:mood_manager/features/mood_manager/data/models/t_mood_model.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_mood.dart';
import 'package:mood_manager/features/mood_manager/presentation/bloc/t_mood_index.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/t_mood_event_calendar.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/t_mood_slidable.dart';
import 'package:mood_manager/injection_container.dart';

class TMoodListPage extends StatefulWidget {
  Map<String, dynamic> arguments = Map();
  List<TMood> tMoodList = [];
  TMood lastSaved;

  TMoodListPage(this.arguments);

  @override
  State<TMoodListPage> createState() => _TMoodListPageState();
}

class _TMoodListPageState extends State<TMoodListPage> {
  TMoodBloc _tMoodBloc;
  List<Widget> views = [];
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mood Entries"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () =>
                BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut()),
          )
        ],
      ),
      body: buildTMoodList(context),
      floatingActionButton: FloatingActionButton(
        onPressed: addTodaysMood,
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
          onTap: onTabTapped,
          currentIndex: currentIndex,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.list), title: Text("List")),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today), title: Text("Calendar")),
          ]),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  addTodaysMood() {
    Navigator.of(context).pushNamed("/add/mood");
  }

  List<Widget> getViews(Map<DateTime, List<TMood>> map) {
    return [
      TMoodSlidable(
        tMoodListMapByDate: map,
        refreshCallback: () {},
        deleteCallback: delete,
        editCallback: edit,
      ),
      TMoodEventCalendar(deleteCallback: delete, editCallback: edit)
    ];
  }

  buildTMoodList(BuildContext context) {
    //debugger();
    return BlocListener<TMoodBloc, TMoodState>(
        listener: (context, state) {
          //debugger();
          if (state is TMoodSaved) {
            widget.lastSaved = state.tMood;
            _tMoodBloc.add(GetTMoodListEvent());
          } else if (state is TMoodListLoaded) {
            // debugger();
            setState(() {
              widget.tMoodList = state.tMoodList;
            });
          }
        },
        cubit: _tMoodBloc,
        child: BlocBuilder<TMoodBloc, TMoodState>(
          cubit: _tMoodBloc,
          builder: (context, state) => getViews(
              TMoodModel.subListMapByDate(widget.tMoodList))[currentIndex],
        ));
  }

  void delete(DateTime date, TMood tMood) {
    //debugger(when: false);
    _tMoodBloc.add(SaveTMoodEvent(
        TMoodModel(
            logDateTime: tMood.logDateTime,
            isActive: false,
            mMood: tMood.mMood,
            note: tMood.note,
            transMoodId: tMood.id),
        []));
  }

  void edit(TMoodModel tMoodModel) {
    Navigator.of(context)
        .pushNamed("/edit", arguments: {'formData': tMoodModel});
  }

  @override
  void initState() {
    super.initState();
    _tMoodBloc = sl<TMoodBloc>();
    _tMoodBloc.add(GetTMoodListEvent());
  }

  @override
  void dispose() {
    super.dispose();
    ResourceUtil.closeBloc(_tMoodBloc);
  }
}
