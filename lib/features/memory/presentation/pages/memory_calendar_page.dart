import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mood_manager/core/constants/app_constants.dart';
import 'package:mood_manager/core/util/color_util.dart';
import 'package:mood_manager/core/util/date_util.dart';
import 'package:mood_manager/features/common/domain/entities/collection.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/common/presentation/widgets/empty_widget.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:mood_manager/features/memory/presentation/bloc/memory_bloc.dart';
import 'package:mood_manager/features/common/data/datasources/common_remote_data_source.dart';
import 'package:mood_manager/features/memory/presentation/pages/memory_list_page.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tinycolor/tinycolor.dart';

class MemoryCalendarPage extends StatefulWidget {
  final Map<dynamic, dynamic> arguments;
  final Function navigateToMemoryForm;
  MemoryCalendarPage({Key key, this.arguments, this.navigateToMemoryForm})
      : super(key: key);

  @override
  _MemoryCalendarPageState createState() => _MemoryCalendarPageState();
}

class _MemoryCalendarPageState extends State<MemoryCalendarPage>
    with RouteAware {
  List<Memory> memoryList = [];
  Map<DateTime, List<Memory>> memoryListMapByDate = {};
  Map<String, Future<List<MediaCollection>>> mediaCollectionListMapByMemory =
      {};
  MemoryBloc _memoryBloc;
  List<DateTime> dateKeys = [];
  AutoScrollController scrollController;
  DateTime selectedDate = DateTime.now();
  CalendarController _calendarController;
  Memory lastSaved;

  @override
  void initState() {
    _memoryBloc = sl<MemoryBloc>();
    _memoryBloc.add(GetMemoryListEvent());
    scrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);
    _calendarController = CalendarController();
    super.initState();
  }

  Map<DateTime, List<Memory>> subListMapByDate(
    List<Memory> memoryList,
  ) {
    return Map.fromEntries(memoryList
        .map((memory) => DateFormat(AppConstants.HEADER_DATE_FORMAT)
            .format(memory.logDateTime))
        .toList()
        .toSet()
        .toList()
        .map((dateStr) => MapEntry<DateTime, List<Memory>>(
            DateFormat(AppConstants.HEADER_DATE_FORMAT).parse(dateStr),
            memoryList
                .where((element) =>
                    DateFormat(AppConstants.HEADER_DATE_FORMAT)
                        .format(element.logDateTime) ==
                    dateStr)
                .toList())));
  }

  Future _scrollToIndex(int index, bool isHighlightAllowOnly) async {
    if (!isHighlightAllowOnly) {
      await scrollController.scrollToIndex(index,
          preferPosition: AutoScrollPosition.middle);
    }
    scrollController.highlight(index, highlightDuration: Duration(seconds: 2));
  }

  Future<void> _refresh() {
    _memoryBloc.add(GetMemoryListEvent());
    return Future.value();
  }

  Widget _wrapScrollTag({int index, Widget child, Color highlightColor}) =>
      AutoScrollTag(
        key: ValueKey(index),
        controller: scrollController,
        index: index,
        child: child,
        highlightColor: highlightColor.withOpacity(0.3),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your memories"),
      ),
      floatingActionButton: AnimatedOpacity(
        opacity: (memoryListMapByDate[DateUtil.getDateOnly(selectedDate)] ?? [])
                .isNotEmpty
            ? 1.0
            : 0.0,
        duration: Duration(milliseconds: 500),
        child: FloatingActionButton(
          onPressed: navigateToMemoryForm,
          child: Icon(
            Icons.add,
          ),
        ),
      ),
      body: BlocConsumer(
        cubit: _memoryBloc,
        listener: (context, state) {
          if (state is MemoryListLoaded) {
            memoryList = state.memoryList;
            memoryListMapByDate = subListMapByDate(memoryList);
            dateKeys = memoryListMapByDate.keys.toList();
            final Map<String, Future<List<MediaCollection>>>
                mediaCollectionMap = {};
            for (final memory in memoryList) {
              mediaCollectionMap[memory.id] = sl<CommonRemoteDataSource>()
                  .getMediaCollectionByCollectionList(memory.collectionList);
            }
            mediaCollectionListMapByMemory = mediaCollectionMap;
            if (lastSaved != null) {
              final scrollIndex = (memoryList ?? [])
                  .indexWhere((element) => element.id == lastSaved.id);
              _scrollToIndex(scrollIndex, false);
              _onDaySelected(
                  lastSaved.logDateTime,
                  memoryListMapByDate[
                      DateUtil.getDateOnly(lastSaved.logDateTime)]);
              lastSaved = null;
            }
          }
        },
        builder: (context, state) {
          final addWidgetButton = Container(
            padding: EdgeInsets.all(8.0),
            child: FlatButton(
              child: Container(
                height: 60,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Add Memory',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              color: Theme.of(context).primaryColor,
              onPressed: navigateToMemoryForm,
            ),
          );
          final memoryListByDate =
              memoryListMapByDate[DateUtil.getDateOnly(selectedDate)];
          return Column(
            children: [
              _buildTableCalendarWithBuilders(memoryListMapByDate),
              Expanded(
                child: ListView(
                    physics: BouncingScrollPhysics(),
                    controller: scrollController,
                    children: [
                      Column(
                        children: [
                          if ((memoryListByDate ?? []).isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(child: Text('No memories')),
                            ),
                          if ((memoryListByDate ?? []).isEmpty) addWidgetButton,
                          if ((memoryListByDate ?? []).isNotEmpty)
                            ..._buildEventList(memoryListByDate)
                        ],
                      ),
                    ]),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTableCalendarWithBuilders(
      Map<DateTime, List<Memory>> tMoodListMapByDate) {
    //
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 0)),
        color: Colors.white,
      ),
      child: TableCalendar(
        endDay: DateTime.now(),
        locale: 'en_US',
        calendarController: _calendarController,
        events: tMoodListMapByDate,
        initialCalendarFormat: CalendarFormat.month,
        initialSelectedDay: selectedDate,
        formatAnimation: FormatAnimation.slide,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        availableGestures: AvailableGestures.all,
        availableCalendarFormats: const {
          CalendarFormat.month: 'Month',
          CalendarFormat.week: 'Week',
        },
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendStyle: TextStyle().copyWith(color: Colors.blue[800]),
          holidayStyle: TextStyle().copyWith(color: Colors.blue[800]),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekendStyle: TextStyle().copyWith(color: Colors.blue[600]),
        ),
        headerStyle: HeaderStyle(
          centerHeaderTitle: true,
          formatButtonVisible: true,
        ),
        builders: CalendarBuilders(
          selectedDayBuilder: (context, date, _) {
            return Container(
              margin: const EdgeInsets.all(4.0),
              padding: const EdgeInsets.only(top: 5.0, left: 6.0),
              color:
                  TinyColor(Theme.of(context).primaryColor).lighten(40).color,
              width: 100,
              height: 100,
              child: Text(
                '${date.day}',
                style: TextStyle(color: Colors.white).copyWith(fontSize: 16.0),
              ),
            );
          },
          todayDayBuilder: (context, date, _) {
            return Container(
              margin: const EdgeInsets.all(4.0),
              padding: const EdgeInsets.only(top: 5.0, left: 6.0),
              color:
                  TinyColor(Theme.of(context).primaryColor).lighten(60).color,
              width: 100,
              height: 100,
              child: Text(
                '${date.day}',
                style: TextStyle().copyWith(fontSize: 16.0),
              ),
            );
          },
          markersBuilder: (context, date, events, holidays) {
            final children = <Widget>[];
            //
            if (events.isNotEmpty) {
              children.add(
                Positioned(
                  right: 1,
                  bottom: 1,
                  child: _buildEventsMarker(date, events),
                ),
              );
            }

            if (holidays.isNotEmpty) {
              children.add(
                Positioned(
                  right: -2,
                  top: -2,
                  child: _buildHolidaysMarker(),
                ),
              );
            }

            return children;
          },
        ),
        onDaySelected: (date, events) {
          _onDaySelected(date, events);
          //_animationController.forward(from: 0.0);
        },
        onVisibleDaysChanged: _onVisibleDaysChanged,
        onCalendarCreated: _onCalendarCreated,
      ),
    );
  }

  Widget _buildHolidaysMarker() {
    return Icon(
      Icons.add_box,
      size: 20.0,
      color: Colors.blueGrey[800],
    );
  }

  void _onDaySelected(DateTime date, List events) {
    print('CALLBACK: _onDaySelected');
    setState(() {
      if (DateUtil.isSameDate(date, DateTime.now())) {
        selectedDate = DateTime.now();
      } else {
        selectedDate = date;
      }
      //widget.selectDate(widget.selectedDate);
      if (events.any((element) => List<Collection>.from(element.collectionList)
          .any((element) => element.mediaCount > 0))) {
        _calendarController.setCalendarFormat(CalendarFormat.week);
      }
    });
  }

  Widget _buildEventsMarker(DateTime date, List<Memory> events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: ColorUtil.mix(
              events.map((e) => e.mMood?.color ?? Colors.grey).toList())),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }

  void _onCalendarCreated(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onCalendarCreated');
  }

  List<Widget> _buildEventList(List<Memory> eventMemoryList) {
    return eventMemoryList
        .map(
          (e) => _wrapScrollTag(
            highlightColor: e.mMood?.color ?? Colors.grey,
            index: memoryList.indexWhere((element) => element == e),
            child: Container(
              padding: EdgeInsets.all(2),
              child: Column(
                children: [
                  Center(
                      child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      DateFormat(DateFormat.HOUR_MINUTE).format(e.logDateTime),
                    ),
                  )),
                  MemoryActivityAndMood(
                    memory: e,
                    tagSuffix: 'CALENDAR',
                  ),
                  FutureBuilder<List<MediaCollection>>(
                    future: mediaCollectionListMapByMemory[e.id],
                    builder: (context, snapshot) {
                      final memory = e;
                      int mediaCount = memory.collectionList.fold(
                          0,
                          (previousValue, element) =>
                              element.mediaCount + previousValue);
                      if (!snapshot.hasData) {
                        return GridPlaceholder(mediaCount: mediaCount);
                      }
                      if ((snapshot.data ?? []).isEmpty) {
                        return EmptyWidget();
                      }
                      return MemoryMediaGrid(
                        mediaCollectionList: snapshot.data,
                      );
                    },
                  ),
                  if ((e.note ?? "").isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Row(children: [
                        Text(e.note),
                      ]),
                    ),
                ],
              ),
            ),
          ),
        )
        .toList();
  }

  void navigateToMemoryForm() async {
    final savedMemory =
        await widget.navigateToMemoryForm({'selectedDate': selectedDate});
    if (savedMemory != null) {
      print(savedMemory.toString());
    }
    if (savedMemory is Memory) {
      lastSaved = savedMemory;
    }
    _memoryBloc.add(GetMemoryListEvent());
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }
}
