import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mood_manager/core/util/resource_util.dart';
import 'package:mood_manager/features/auth/presentation/bloc/authentication_bloc.dart';
import 'package:mood_manager/features/mood_manager/data/models/t_mood_model.dart';
import 'package:mood_manager/features/mood_manager/data/streams/stream_service.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_mood.dart';
import 'package:mood_manager/features/mood_manager/presentation/bloc/t_mood_index.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/t_mood_event_calendar.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/t_mood_slidable.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:provider/provider.dart';

class TMoodListPage extends StatefulWidget {
  Map<String, dynamic> arguments = Map();
  List<TMood> tMoodList;

  TMoodListPage(this.arguments);

  @override
  State<TMoodListPage> createState() => _TMoodListPageState();
}

class _TMoodListPageState extends State<TMoodListPage> {
  TMoodBloc _tMoodBloc;
  List<Widget> views = [];
  int currentIndex = 0;

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

  List<Widget> getViews() {
    return [
      TMoodSlidable(
        refreshCallback: () {},
        /* tMoodListGroupByDate:
                    TMoodModel.subListMapByDate(snapshot.data ?? []),*/
        deleteCallback: delete,
        editCallback: edit,
      ),
      TMoodEventCalendar(
          /* tMoodListGroupByDate:
                  TMoodModel.subListMapByDate(snapshot.data ?? []),*/
          deleteCallback: delete,
          editCallback: edit)
    ];
  }

  buildTMoodList(BuildContext context) {
    return StreamBuilder<List<TMood>>(
        stream: sl<StreamService>().tMoodList,
        builder: (context, snapshot) {
          return StreamProvider<List<MapEntry<DateTime, List<TMood>>>>.value(
            initialData: [],
            value: Stream.value(TMoodModel.subListMapByDate(snapshot.data ?? [])
                .entries
                .toList()),
            child: getViews()[currentIndex],
          );
        });
  }

  void delete(DateTime date, TMoodModel tMoodModel) {
    setState(() {});
    _tMoodBloc.add(SaveTMoodEvent(TMoodModel(
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

  @override
  void initState() {
    super.initState();
    setState(() {
      onTabTapped(0);
    });
    sl<StreamService>().tMoodList.listen((event) {
      setState(() {
        widget.tMoodList = event;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    ResourceUtil.closeBloc(_tMoodBloc);
  }
}
