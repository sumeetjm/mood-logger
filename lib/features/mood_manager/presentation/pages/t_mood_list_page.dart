import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mood_manager/core/constants/app_constants.dart';
import 'package:mood_manager/core/util/date_util.dart';
import 'package:mood_manager/features/auth/presentation/bloc/authentication_bloc.dart';
import 'package:mood_manager/features/mood_manager/data/models/parse/t_mood_parse.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/t_mood.dart';
import 'package:mood_manager/features/mood_manager/presentation/bloc/t_mood_index.dart';
import 'package:mood_manager/features/common/presentation/widgets/empty_widget.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/t_mood_event_calendar.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/t_mood_slidable.dart';
import 'package:intl/intl.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class TMoodListPage extends StatefulWidget {
  Map<String, dynamic> arguments = Map();
  TMood lastSaved;
  String lastAction;
  List<TMood> tMoodList = [];
  Map<DateTime, List<TMood>> tMoodListMapByDate = {};
  DateTime newSelectedDate = DateTime.now();

  TMoodListPage({this.arguments});

  @override
  State<TMoodListPage> createState() => _TMoodListPageState();
}

class _TMoodListPageState extends State<TMoodListPage> {
  Map<int, String> viewMap = ['LIST', 'CALENDAR'].asMap();
  TMoodBloc _tMoodBloc;
  AutoScrollController scrollController;
  Widget getView(index) => [
        TMoodSlidable(
            tMoodList: widget.tMoodList,
            refreshCallback: _refresh,
            deleteCallback: delete,
            editCallback: edit,
            scrollController: scrollController),
        TMoodEventCalendar(
          tMoodListMapByDate: widget.tMoodListMapByDate,
          deleteCallback: delete,
          editCallback: edit,
          selectDate: (date) => widget.newSelectedDate = date,
          selectedDate: widget.newSelectedDate,
          scrollController: scrollController,
          refreshCallback: _refresh,
        )
      ][index];
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mood Entries'),
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
        backgroundColor: Theme.of(context).buttonColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
          onTap: onTabTapped,
          currentIndex: currentIndex,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.list), title: Text('List')),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today), title: Text('Calendar')),
          ]),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
      widget.newSelectedDate = DateTime.now();
      resetScrollParams();
    });
  }

  addTodaysMood() {
    Navigator.of(context).pushNamed('/add/mood',
        arguments: {'selectedDate': widget.newSelectedDate});
  }

  Future<Null> _refresh() {
    setState(() {
      resetScrollParams();
    });
    _tMoodBloc.add(GetTMoodListEvent());
    return Future.value();
  }

  void resetScrollParams() {
    widget.lastSaved = null;
    widget.lastAction = null;
  }

  buildTMoodList(BuildContext context) {
    /*BlocConsumer(
        cubit: _tMoodBloc,
        builder: null,
        listener: (context, state) {
          if (state is TMoodSaved) {
            widget.lastSaved = state.tMood;
            widget.lastAction = state.action;
            if (currentIndex == 1) {
              widget.newSelectedDate = widget.lastSaved.logDateTime;
            } else {
              widget.newSelectedDate = DateTime.now();
            }
            _tMoodBloc.add(GetTMoodListEvent());
          } else if (state is TMoodListLoaded) {
            widget.tMoodList = state.tMoodList;
            widget.tMoodListMapByDate =
                TMoodParse.subListMapByDate(widget.tMoodList);
          }
        });*/
    return BlocListener<TMoodBloc, TMoodState>(
        listener: (context, state) {
          if (state is TMoodSaved) {
            widget.lastSaved = state.tMood;
            widget.lastAction = state.action;
            if (currentIndex == 1) {
              widget.newSelectedDate = widget.lastSaved.logDateTime;
            } else {
              widget.newSelectedDate = DateTime.now();
            }
            _tMoodBloc.add(GetTMoodListEvent());
          } else if (state is TMoodListLoaded) {
            widget.tMoodList = state.tMoodList;
            widget.tMoodListMapByDate =
                TMoodParse.subListMapByDate(widget.tMoodList);
          }
        },
        cubit: _tMoodBloc,
        child: BlocBuilder<TMoodBloc, TMoodState>(
          cubit: _tMoodBloc,
          buildWhen: (previous, current) => current is TMoodListLoaded,
          builder: (context, state) {
            if (widget.lastSaved != null &&
                AppConstants.ACTION['DELETE'] != widget.lastAction) {
              var lastSavedIndex;
              if (viewMap[currentIndex] == 'CALENDAR') {
                lastSavedIndex = (widget.tMoodListMapByDate[
                            DateUtil.getDateOnly(widget.newSelectedDate)] ??
                        [])
                    .indexWhere((element) => element.id == widget.lastSaved.id);
              } else {
                lastSavedIndex = (widget.tMoodList ?? [])
                    .indexWhere((element) => element.id == widget.lastSaved.id);
              }
              _scrollToIndex(lastSavedIndex,
                  AppConstants.ACTION['UPDATE'] == widget.lastAction);
            }
            if (widget.tMoodListMapByDate != null &&
                widget.tMoodListMapByDate.length > 0) {
              return getView(currentIndex);
            }
            return EmptyWidget();
          },
        ));
  }

  DateTime getDateOnly(DateTime dateTime) {
    return DateFormat(DateFormat.YEAR_NUM_MONTH_DAY)
        .parse(DateFormat(DateFormat.YEAR_NUM_MONTH_DAY).format(dateTime));
  }

  void delete(DateTime date, TMood tMood) {
    _tMoodBloc.add(SaveTMoodEvent(
        TMoodParse(
            logDateTime: tMood.logDateTime,
            isActive: false,
            mMood: tMood.mMood,
            note: tMood.note,
            transMoodId: tMood.id,
            tActivityList: tMood.tActivityList),
        AppConstants.ACTION['DELETE']));
  }

  void edit(TMood tMood) {
    Navigator.of(context).pushNamed('/edit', arguments: {'formData': tMood});
  }

  Future _scrollToIndex(int index, bool isHighlightAllowOnly) async {
    if (!isHighlightAllowOnly) {
      await scrollController.scrollToIndex(index,
          preferPosition: AutoScrollPosition.middle);
    }
    scrollController.highlight(index, highlightDuration: Duration(seconds: 2));
  }

  @override
  void initState() {
    super.initState();
    _tMoodBloc = BlocProvider.of<TMoodBloc>(context);
    _tMoodBloc.add(GetTMoodListEvent());
    scrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
