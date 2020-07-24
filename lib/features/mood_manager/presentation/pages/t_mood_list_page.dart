import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mood_manager/core/util/resource_util.dart';
import 'package:mood_manager/features/auth/presentation/bloc/authentication_bloc.dart';
import 'package:mood_manager/features/mood_manager/data/models/t_mood_model.dart';
import 'package:mood_manager/features/mood_manager/presentation/bloc/t_mood_index.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/loading_bar.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/t_mood_event_calendar.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/t_mood_slidable.dart';
import 'package:mood_manager/injection_container.dart';

class TMoodListPage extends StatefulWidget {
  Map<DateTime, List<TMoodModel>> tMoodListListGroupByDate = Map();
  Map<String, dynamic> arguments = Map();
  bool isLoading = true;

  TMoodListPage(this.arguments);

  @override
  State<TMoodListPage> createState() => _TMoodListPageState();
}

class _TMoodListPageState extends State<TMoodListPage> {
  TMoodBloc _tMoodBloc;
  StreamSubscription<TMoodState> _tMoodListener;
  List<Widget> views = [];
  int currentIndex;

  _TMoodListPageState() {
    _tMoodBloc = sl<TMoodBloc>();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mood Entries"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () =>
                {BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut())},
          )
        ],
        bottom: PreferredSize(
            child: LoadingBar(widget.isLoading),
            preferredSize: Size.fromHeight(4.0)),
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

  List<Widget> getViews() {
    return [
      TMoodSlidable(
        tMoodListGroupByDate: widget.tMoodListListGroupByDate,
        deleteCallback: delete,
        editCallback: edit,
        refreshCallback: refresh,
      ),
      TMoodEventCalendar(
          tMoodListGroupByDate: widget.tMoodListListGroupByDate,
          deleteCallback: delete,
          editCallback: edit),
    ];
  }

  buildTMoodList(BuildContext context) {
    return getViews()[currentIndex];
  }

  void delete(DateTime date, TMoodModel tMoodModel) {
    setState(() {
      widget.tMoodListListGroupByDate[date].remove(tMoodModel);
    });
    _tMoodBloc.add(SaveTMoodEvent(TMoodModel(
        moodName: tMoodModel.moodName,
        moodCode: tMoodModel.moodCode,
        logDateTime: tMoodModel.logDateTime,
        isActive: false,
        mMoodModel: tMoodModel.mMood,
        note: tMoodModel.note,
        tActivityModelList: tMoodModel.tActivityList,
        transMoodId: tMoodModel.transMoodId)));
  }

  void edit(TMoodModel tMoodModel) {
    Navigator.of(context)
        .pushNamed("/edit", arguments: {'formData': tMoodModel});
  }

  Future<void> refresh() async {
    setState(() {
      widget.isLoading = true;
    });
    _tMoodBloc.add(GetTMoodListEvent());
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      views = getViews();
      onTabTapped(0);
      widget.isLoading = true;
    });
    _tMoodBloc.add(GetTMoodListEvent());
    _tMoodListener = _tMoodBloc.listen((state) {
      if (state is TMoodListLoaded) {
        setState(() {
          widget.tMoodListListGroupByDate =
              TMoodModel.subListMapByDate(state.tMoodList);
          widget.isLoading = false;
        });
      } else if (state is TMoodSaved) {
        _tMoodBloc.add(GetTMoodListEvent());
        setState(() {
          widget.isLoading = true;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    ResourceUtil.closeBloc(_tMoodBloc);
    ResourceUtil.closeSubscription(_tMoodListener);
  }
}
