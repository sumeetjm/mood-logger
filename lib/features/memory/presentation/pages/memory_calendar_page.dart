import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mood_manager/core/constants/app_constants.dart';
import 'package:mood_manager/core/util/color_util.dart';
import 'package:mood_manager/core/util/date_util.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/common/presentation/widgets/empty_widget.dart';
import 'package:mood_manager/features/common/presentation/widgets/media_page_view.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:mood_manager/features/memory/presentation/bloc/memory_bloc.dart';
import 'package:mood_manager/features/common/data/datasources/common_remote_data_source.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:intl/intl.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tinycolor/tinycolor.dart';

class MemoryCalendarPage extends StatefulWidget {
  final Map<dynamic, dynamic> arguments;
  MemoryCalendarPage({Key key, this.arguments}) : super(key: key);

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
        body: Container(
          child: BlocConsumer(
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
                      .getMediaCollectionByCollectionList(
                          memory.collectionList);
                }
                mediaCollectionListMapByMemory = mediaCollectionMap;
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
                  onPressed: navigateToAddMemory,
                ),
              );
              final memoryListByDate =
                  memoryListMapByDate[DateUtil.getDateOnly(selectedDate)];
              return SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: StickyHeader(
                    header:
                        _buildTableCalendarWithBuilders(memoryListMapByDate),
                    content: Column(
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
                  ));
            },
          ),
        ));
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
          CalendarFormat.month: '',
          CalendarFormat.week: '',
          CalendarFormat.twoWeeks: '',
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
          formatButtonVisible: false,
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

  List<Widget> _buildEventList(List<Memory> memoryList) {
    return memoryList
        .asMap()
        .keys
        .map((index) => _wrapScrollTag(
            highlightColor: memoryList[index].mMood?.color ?? Colors.grey,
            index: index,
            child: Container(
              padding: EdgeInsets.all(2),
              child: Column(
                children: [
                  Center(
                      child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      DateFormat(DateFormat.HOUR_MINUTE)
                          .format(memoryList[index].logDateTime),
                    ),
                  )),
                  Card(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          color: (memoryList[index].mMood?.color ?? Colors.grey)
                              .withOpacity(0.2),
                          height: 50,
                          width: (MediaQuery.of(context).size.width / 2) - 8,
                          child: Center(
                            child: Text(
                              memoryList[index].mActivityList.isEmpty
                                  ? 'No Activity'
                                  : memoryList[index]
                                      .mActivityList
                                      .map((e) => e.activityName)
                                      .toList()
                                      .join(" | "),
                            ),
                          ),
                        ),
                        Container(
                          color: (memoryList[index].mMood?.color ?? Colors.grey)
                              .withOpacity(0.2),
                          height: 50,
                          width: (MediaQuery.of(context).size.width / 2) - 4,
                          child: Row(children: [
                            CircleAvatar(
                              backgroundColor:
                                  (memoryList[index].mMood?.color ??
                                      Colors.grey),
                              radius: 15,
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Text(memoryList[index].mMood?.moodName ??
                                'No Mood'.toUpperCase())
                          ]),
                        ),
                      ],
                    ),
                  ),
                  FutureBuilder<List<MediaCollection>>(
                    future:
                        mediaCollectionListMapByMemory[memoryList[index].id],
                    builder: (context, snapshot) {
                      int mediaCount = memoryList[index].collectionList.fold(
                          0,
                          (previousValue, element) =>
                              element.mediaCount + previousValue);
                      if (!snapshot.hasData) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: GridView.count(
                              crossAxisCount: mediaCount == 1 ? 1 : 2,
                              crossAxisSpacing: 1,
                              mainAxisSpacing: 1,
                              physics:
                                  NeverScrollableScrollPhysics(), // to disable GridView's scrolling
                              shrinkWrap: true,
                              children: List.generate(
                                mediaCount >= 4 ? 4 : mediaCount,
                                (index) => Container(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                    border: Border.all(
                                        color: Colors.grey[400], width: 1),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          gradient: new LinearGradient(
                                              colors: [
                                            Colors.white,
                                            Colors.grey,
                                          ],
                                              stops: [
                                            0.0,
                                            1.0
                                          ],
                                              begin: FractionalOffset.topCenter,
                                              end:
                                                  FractionalOffset.bottomCenter,
                                              tileMode: TileMode.mirror)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      if ((snapshot.data ?? []).isEmpty) {
                        return EmptyWidget();
                      }
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: GridView.builder(
                            itemCount: snapshot.data.length >= 4
                                ? 4
                                : snapshot.data.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: snapshot.data.length == 1 ? 1 : 2,
                              crossAxisSpacing: 1,
                              mainAxisSpacing: 1,
                            ),

                            itemBuilder: (context, index) {
                              if (index == 3 &&
                                  (snapshot.data.length - 3 > 1)) {
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                    border: Border.all(
                                        color: Colors.grey[400], width: 1),
                                  ),
                                  child: Stack(
                                    children: [
                                      Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                return MediaPageView(
                                                  mediaCollectionList:
                                                      snapshot.data,
                                                  initialItem:
                                                      snapshot.data[index],
                                                );
                                              }));
                                            },
                                            child: ColorFiltered(
                                                colorFilter: ColorFilter.mode(
                                                  Colors.black.withOpacity(0.4),
                                                  BlendMode.darken,
                                                ),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.grey,
                                                        width: 1),
                                                  ),
                                                  child: GridView.builder(
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    itemCount:
                                                        snapshot.data.length -
                                                            3,
                                                    gridDelegate:
                                                        SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 2,
                                                      crossAxisSpacing: 2,
                                                      mainAxisSpacing: 2,
                                                    ),
                                                    itemBuilder:
                                                        (context, index) {
                                                      final newIndex =
                                                          index + 3;
                                                      return Container(
                                                        child:
                                                            CachedNetworkImage(
                                                          fit: BoxFit.cover,
                                                          imageUrl: snapshot
                                                              .data[newIndex]
                                                              .media
                                                              .thumbnail
                                                              .url,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                )),
                                          )),
                                      Center(
                                        child: Text(
                                          (snapshot.data.length - 3)
                                                  .toString() +
                                              " more",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  border: Border.all(
                                      color: Colors.grey[400], width: 1),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                        return MediaPageView(
                                          mediaCollectionList: snapshot.data,
                                          initialItem: snapshot.data[index],
                                        );
                                      }));
                                    },
                                    child: Hero(
                                      tag: snapshot.data[index].media.id,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey, width: 1),
                                        ),
                                        child: CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          imageUrl: snapshot.data.length == 1
                                              ? snapshot
                                                  .data[index].media.file.url
                                              : snapshot.data[index].media
                                                  .thumbnail.url,
                                          errorWidget: (context, url, error) =>
                                              new Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            physics:
                                NeverScrollableScrollPhysics(), // to disable GridView's scrolling
                            shrinkWrap:
                                true, // You won't see infinite size error
                          ),
                        ),
                      );
                    },
                  ),
                  if ((memoryList[index].note ?? "").isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Row(children: [
                        Text(memoryList[index].note),
                      ]),
                    ),
                ],
              ),
            )))
        .toList();
  }

  navigateToAddMemory() {
    Navigator.pushNamed(context, '/add/memory');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _calendarController.dispose();
    super.dispose();
  }
}
