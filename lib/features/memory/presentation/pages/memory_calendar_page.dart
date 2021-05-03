import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mood_manager/core/constants/app_constants.dart';
import 'package:mood_manager/core/util/color_util.dart';
import 'package:mood_manager/core/util/date_util.dart';
import 'package:mood_manager/features/common/domain/entities/base_states.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection_mapping.dart';
import 'package:mood_manager/features/common/presentation/widgets/empty_widget.dart';
import 'package:mood_manager/features/common/presentation/widgets/media_page_view.dart';
import 'package:mood_manager/features/memory/data/models/memory_collection_mapping_parse.dart';
import 'package:mood_manager/features/memory/data/models/memory_collection_parse.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:mood_manager/features/memory/domain/entities/memory_collection.dart';
import 'package:mood_manager/features/memory/presentation/bloc/memory_bloc.dart';
import 'package:mood_manager/features/common/data/datasources/common_remote_data_source.dart';
import 'package:mood_manager/features/memory/presentation/pages/memory_list_page.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:intl/intl.dart';
import 'package:sliding_panel/sliding_panel.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tinycolor/tinycolor.dart';
import 'package:uuid/uuid.dart';
import 'package:mood_manager/features/memory/data/datasources/memory_remote_data_source.dart';

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
  Map<String, Future<List<MediaCollectionMapping>>>
      mediaCollectionMappingListMapByMemory = {};
  MemoryBloc _memoryBloc;
  List<DateTime> dateKeys = [];
  AutoScrollController scrollController;
  DateTime selectedDate = DateTime.now();
  CalendarController _calendarController;
  MapEntry<String, Memory> lastSavedWithActionType;
  String uniqueKey;
  final Uuid uuid = sl<Uuid>();
  String moduleKey;

  @override
  void initState() {
    _memoryBloc = BlocProvider.of<MemoryBloc>(context);
    //_memoryBloc.add(GetMemoryListEvent());
    scrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);
    _calendarController = CalendarController();
    uniqueKey = uuid.v1();
    moduleKey = 'LIST';
    super.initState();
  }

  Future _scrollToIndex(int index) async {
    await scrollController.scrollToIndex(index,
        preferPosition: AutoScrollPosition.middle);
    scrollController.highlight(index, highlightDuration: Duration(seconds: 2));
  }

  Future<void> _refresh() {
    _memoryBloc.add(GetMemoryListEvent());
    return Future.value();
  }

  deleteMemory(memory) async {
    memory.isActive = false;
    _memoryBloc.add(SaveMemoryEvent(
      memory: memory,
      mediaCollectionMappingList:
          await mediaCollectionMappingListMapByMemory[memory.id],
    ));
  }

  archiveMemory(memory) async {
    _memoryBloc.add(ArchiveMemoryEvent(
        memory: memory,
        mediaCollectionMappingList:
            await mediaCollectionMappingListMapByMemory[memory.id]));
  }

  addToCollection(Memory memory) async {
    MemoryCollection result;
    sl<MemoryRemoteDataSource>().getMemoryCollectionList().then((value) async {
      result = await showModalSlidingPanel(
        context: context,
        panel: (context) {
          final pc = PanelController();
          return SlidingPanel(
            panelController: pc,
            safeAreaConfig: SafeAreaConfig.all(removePaddingFromContent: true),
            backdropConfig: BackdropConfig(enabled: true),
            isTwoStatePanel: true,
            snapping: PanelSnapping.forced,
            size: PanelSize(closedHeight: 0.00, expandedHeight: 0.8),
            autoSizing: PanelAutoSizing(
                autoSizeExpanded: true, headerSizeIsClosed: true),
            duration: Duration(milliseconds: 500),
            initialState: InitialPanelState.expanded,
            content: PanelContent(
              panelContent: panelContentCollectionOptions(context, value),
              headerWidget: PanelHeaderWidget(
                headerContent: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add to collection',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      CloseButton(),
                    ]),
                options: PanelHeaderOptions(
                  centerTitle: true,
                  elevation: 4,
                  forceElevated: true,
                  primary: false,
                ),
                decoration: PanelDecoration(padding: EdgeInsets.all(16)),
              ),
            ),
          );
        },
      );
      if (result != null) {
        _memoryBloc.add(AddMemoryToCollectionEvent(MemoryCollectionMappingParse(
            memory: memory,
            memoryCollection:
                result.incrementMemoryCount().addColor(memory.mMood?.color))));
      }
    });
  }

  List<Widget> panelContentCollectionOptions(
      BuildContext context, List<MemoryCollection> value) {
    return [
      ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(
            MdiIcons.bookPlus,
            color: Colors.white,
          ),
        ),
        title: Text('Create new collection'),
        onTap: () async {
          var newMemoryCollection = MemoryCollectionParse();
          var collectionName = await showNewMemoryCollectionDialog(context);

          newMemoryCollection.name = collectionName;
          Navigator.of(context).pop(newMemoryCollection);
        },
      ),
      Divider(
        thickness: 1,
        height: 1,
      ),
      ...value
          .map((e) => [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: e.averageMemoryMoodColor,
                    child: Icon(
                      MdiIcons.book,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(e.name),
                  onTap: () {
                    Navigator.of(context).pop(e);
                  },
                ),
                Divider(
                  thickness: 1,
                  height: 3,
                ),
              ])
          .expand((element) => element)
          .toList()
    ];
  }

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
          heroTag: uniqueKey,
          onPressed: navigateToMemoryForm,
          child: Icon(
            Icons.add,
          ),
        ),
      ),
      body: BlocConsumer<MemoryBloc, MemoryState>(
        cubit: _memoryBloc,
        listener: (context, state) {
          if (state is MemoryListLoaded) {
            Loader.hide();
            memoryList = state.memoryList;
            memoryListMapByDate = subListMapByDate(memoryList);
            dateKeys = memoryListMapByDate.keys.toList();
            final Map<String, Future<List<MediaCollectionMapping>>>
                mediaCollectionMappingMap = {};
            for (final memory in memoryList) {
              mediaCollectionMappingMap[memory.id] =
                  sl<CommonRemoteDataSource>()
                      .getMediaCollectionMappingByCollectionList(
                          memory.mediaCollectionList);
            }
            mediaCollectionMappingListMapByMemory = mediaCollectionMappingMap;
            if (lastSavedWithActionType != null) {
              final scrollIndex = (memoryList ?? []).indexWhere(
                  (element) => element.id == lastSavedWithActionType.value.id);
              _scrollToIndex(scrollIndex);
              _onDaySelected(
                  lastSavedWithActionType.value.logDateTime,
                  memoryListMapByDate[DateUtil.getDateOnly(
                      lastSavedWithActionType.value.logDateTime)]);
              lastSavedWithActionType = null;
            }
          } else if (state is MemorySaved) {
            Loader.hide();
            _memoryBloc.add(GetMemoryListEvent());
          }
          if (state is Loading) {
            Loader.show(context,
                overlayColor: Colors.black.withOpacity(0.5),
                isAppbarOverlay: true,
                isBottomBarOverlay: true,
                progressIndicator: RefreshProgressIndicator());
          } else if (state is Completed) {
            Loader.hide();
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
                child: RefreshIndicator(
                  onRefresh: _refresh,
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
                            if ((memoryListByDate ?? []).isEmpty)
                              addWidgetButton,
                            if ((memoryListByDate ?? []).isNotEmpty)
                              ..._buildEventList(memoryListByDate),
                            SizedBox(height: 250),
                          ],
                        ),
                      ]),
                ),
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
        onDaySelected: (date, events, holidays) {
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
      if (events.any((element) =>
          List<MediaCollection>.from(element.mediaCollectionList)
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
          (e) => wrapScrollTag(
            controller: scrollController,
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
                    navigateToMemoryForm: navigateToMemoryForm,
                    archiveMemory: archiveMemory,
                    deleteMemory: deleteMemory,
                    addToCollection: addToCollection,
                  ),
                  FutureBuilder<List<MediaCollectionMapping>>(
                    future: mediaCollectionMappingListMapByMemory[e.id],
                    builder: (context, snapshot) {
                      final memory = e;
                      int mediaCount = memory.mediaCollectionList.fold(
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
                        navigateToMediaPageView: (index) {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return MediaPageView(
                              mediaCollectionList: snapshot.data,
                              initialIndex: index,
                            );
                          }));
                        },
                      );
                    },
                  ),
                  if ((e.note ?? "").isNotEmpty) MemoryNote(memory: e),
                ],
              ),
            ),
          ),
        )
        .toList();
  }

  void navigateToMemoryForm({Memory memory}) async {
    final savedMemoryWithActionType = await Navigator.of(context).pushNamed(
        '/memory/add',
        arguments: {'memory': memory, 'selectedDate': selectedDate});
    lastSavedWithActionType = savedMemoryWithActionType;
    _memoryBloc.add(GetMemoryListEvent());
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }
}
