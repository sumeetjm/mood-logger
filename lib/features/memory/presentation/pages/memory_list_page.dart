import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mood_manager/core/constants/app_constants.dart';
import 'package:mood_manager/features/common/data/datasources/common_remote_data_source.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/common/presentation/widgets/empty_widget.dart';
import 'package:mood_manager/features/common/presentation/widgets/media_page_view.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:mood_manager/features/memory/presentation/bloc/memory_bloc.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:intl/intl.dart';

class MemoryListPage extends StatefulWidget {
  final Map<dynamic, dynamic> arguments;
  DateTime calendarSelectedDate;
  List<Memory> memoryList;
  final Function navigateToMemoryForm;
  MemoryListPage({Key key, this.arguments, this.navigateToMemoryForm})
      : super(key: key) {
    if (arguments != null) {
      this.calendarSelectedDate = this.arguments['selectedDate'];
      this.memoryList = this.arguments['memoryList'];
    }
  }

  @override
  _MemoryListPageState createState() => _MemoryListPageState();
}

class _MemoryListPageState extends State<MemoryListPage> {
  List<Memory> memoryList = [];
  Map<DateTime, List<Memory>> memoryListMapByDate = {};
  Map<String, Future<List<MediaCollection>>> mediaCollectionListMapByMemory =
      {};
  MemoryBloc _memoryBloc;
  List<DateTime> dateKeys = [];
  AutoScrollController scrollController;
  Memory lastSaved;

  @override
  void initState() {
    super.initState();
    _memoryBloc = sl<MemoryBloc>();
    if (widget.calendarSelectedDate != null) {
      memoryList = widget.memoryList;
      memoryListMapByDate = subListMapByDate(memoryList);
      dateKeys = memoryListMapByDate.keys.toList();
      final Map<String, Future<List<MediaCollection>>> mediaCollectionMap = {};
      for (final memory in memoryList) {
        mediaCollectionMap[memory.id] = sl<CommonRemoteDataSource>()
            .getMediaCollectionByCollectionList(memory.collectionList);
      }
      mediaCollectionListMapByMemory = mediaCollectionMap;
    } else {
      _memoryBloc.add(GetMemoryListEvent());
    }
    scrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);
  }

  Map<DateTime, List<Memory>> subListMapByDate(
    List<Memory> memoryList,
  ) =>
      Map.fromEntries(memoryList
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

  Future _scrollToIndex(int index, bool isHighlightAllowOnly) async {
    if (!isHighlightAllowOnly) {
      await scrollController.scrollToIndex(index,
          preferPosition: AutoScrollPosition.middle);
    }
    scrollController.highlight(index, highlightDuration: Duration(seconds: 2));
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
            decoration: BoxDecoration(
              image: DecorationImage(
                  image:
                      AssetImage("assets/grey_abstract_geometric_triangle.jpg"),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.linearToSrgbGamma()),
            ),
            child: BlocConsumer<MemoryBloc, MemoryState>(
                cubit: _memoryBloc,
                listener: (context, state) {
                  if (state is MemoryListLoaded) {
                    memoryList = state.memoryList;
                    memoryListMapByDate = subListMapByDate(memoryList);
                    dateKeys = memoryListMapByDate.keys.toList();
                    final Map<String, Future<List<MediaCollection>>>
                        mediaCollectionMap = {};
                    for (final memory in memoryList) {
                      mediaCollectionMap[memory.id] =
                          sl<CommonRemoteDataSource>()
                              .getMediaCollectionByCollectionList(
                                  memory.collectionList);
                    }
                    mediaCollectionListMapByMemory = mediaCollectionMap;
                    if (lastSaved != null) {
                      final scrollIndex = (memoryList ?? [])
                          .indexWhere((element) => element.id == lastSaved.id);
                      _scrollToIndex(scrollIndex, false);
                    }
                  }
                },
                builder: (context, state) {
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.builder(
                      controller: scrollController,
                      physics: BouncingScrollPhysics(),
                      itemCount: (memoryListMapByDate ?? {}).length,
                      itemBuilder: (context, index) {
                        final memoryListDateWise =
                            memoryListMapByDate[dateKeys[index]];
                        return StickyHeader(
                            header: Center(
                                child: Container(
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                    ),
                                    child: Center(
                                        child: Text(
                                      DateFormat(
                                              AppConstants.HEADER_DATE_FORMAT)
                                          .format(dateKeys[index]),
                                      style: TextStyle(
                                          color: Colors.grey[50],
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.italic),
                                    )))),
                            content: ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: memoryListDateWise.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final memory = memoryListDateWise[index];
                                final mediaCount = memory.collectionList.fold(
                                    0,
                                    (previousValue, element) =>
                                        element.mediaCount + previousValue);
                                return _wrapScrollTag(
                                    index: memoryList.indexWhere(
                                        (element) => element.id == memory.id),
                                    highlightColor:
                                        (memory.mMood?.color ?? Colors.grey),
                                    child: Container(
                                      padding: EdgeInsets.all(2),
                                      child: Column(
                                        children: [
                                          MemoryTime(memory: memory),
                                          MemoryActivityAndMood(
                                            memory: memory,
                                            tagSuffix: 'LIST',
                                          ),
                                          if (mediaCount > 0)
                                            FutureBuilder<
                                                List<MediaCollection>>(
                                              future:
                                                  mediaCollectionListMapByMemory[
                                                      memory.id],
                                              builder: (context, snapshot) {
                                                if (!snapshot.hasData) {
                                                  return GridPlaceholder(
                                                      mediaCount: mediaCount);
                                                }
                                                if ((snapshot.data ?? [])
                                                    .isEmpty) {
                                                  return EmptyWidget();
                                                }
                                                return MemoryMediaGrid(
                                                  mediaCollectionList:
                                                      snapshot.data,
                                                );
                                              },
                                            ),
                                          if ((memory.note ?? "").isNotEmpty)
                                            MemoryNote(memory: memory),
                                        ],
                                      ),
                                    ));
                              },
                            ));
                      },
                    ),
                  );
                })));
  }

  Future<void> _refresh() {
    if (widget.calendarSelectedDate != null) {
      _memoryBloc.add(GetMemoryListByDateEvent(widget.calendarSelectedDate));
    } else {
      _memoryBloc.add(GetMemoryListEvent());
    }
    return Future.value();
  }

  void navigateToMemoryForm() async {
    final savedMemory = await widget.navigateToMemoryForm();
    lastSaved = savedMemory;
    if (widget.calendarSelectedDate != null) {
      _memoryBloc.add(GetMemoryListByDateEvent(widget.calendarSelectedDate));
    } else {
      _memoryBloc.add(GetMemoryListEvent());
    }
  }

  @override
  void dispose() {
    _memoryBloc.close();
    super.dispose();
  }
}

class MemoryNote extends StatelessWidget {
  const MemoryNote({
    Key key,
    @required this.memory,
  }) : super(key: key);

  final Memory memory;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(children: [
        Text(memory.note),
      ]),
    );
  }
}

class MemoryMediaGrid extends StatelessWidget {
  final List<MediaCollection> mediaCollectionList;
  const MemoryMediaGrid({Key key, this.mediaCollectionList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: GridView.builder(
          itemCount:
              mediaCollectionList.length >= 4 ? 4 : mediaCollectionList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: mediaCollectionList.length == 1 ? 1 : 2,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
          ),

          itemBuilder: (context, index) {
            if (index == 3 && (mediaCollectionList.skip(index).length > 1)) {
              return MemoryMiniGrid(
                mediaCollectionList: mediaCollectionList,
                index: index,
              );
            }
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                border: Border.all(color: Colors.grey[400], width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return MediaPageView(
                        mediaCollectionList: mediaCollectionList,
                        initialItem: mediaCollectionList[index],
                      );
                    }));
                  },
                  child: Hero(
                    tag: mediaCollectionList[index].media.id,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: mediaCollectionList.length == 1
                            ? mediaCollectionList[index].media.file.url
                            : mediaCollectionList[index].media.thumbnail.url,
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
          shrinkWrap: true, // You won't see infinite size error
        ),
      ),
    );
  }
}

class MemoryMiniGrid extends StatelessWidget {
  final int index;
  const MemoryMiniGrid({
    Key key,
    @required this.mediaCollectionList,
    @required this.index,
  }) : super(key: key);

  final List<MediaCollection> mediaCollectionList;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        border: Border.all(color: Colors.grey[400], width: 1),
      ),
      child: Stack(
        children: [
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return MediaPageView(
                      mediaCollectionList: mediaCollectionList,
                      initialItem: mediaCollectionList[index],
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
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                      child: GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: mediaCollectionList.length - 3,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 2,
                        ),
                        itemBuilder: (context, index) {
                          final newIndex = index + 3;
                          return Container(
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: mediaCollectionList[newIndex]
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
              (mediaCollectionList.length - 3).toString() + " more",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class GridPlaceholder extends StatelessWidget {
  const GridPlaceholder({
    Key key,
    @required this.mediaCount,
  }) : super(key: key);

  final num mediaCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: mediaCount == 1 ? 1 : 2,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
          ),
          itemCount: mediaCount >= 4 ? 4 : mediaCount,
          physics:
              NeverScrollableScrollPhysics(), // to disable GridView's scrolling
          shrinkWrap: true,
          itemBuilder: (context, index) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              border: Border.all(color: Colors.grey[400], width: 1),
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
                        end: FractionalOffset.bottomCenter,
                        tileMode: TileMode.mirror)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MemoryTime extends StatelessWidget {
  const MemoryTime({
    Key key,
    @required this.memory,
  }) : super(key: key);

  final Memory memory;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(4),
      child: Text(
        DateFormat(DateFormat.HOUR_MINUTE).format(memory.logDateTime),
      ),
    ));
  }
}

class MemoryActivityAndMood extends StatelessWidget {
  const MemoryActivityAndMood({
    Key key,
    @required this.memory,
    @required this.tagSuffix,
  }) : super(key: key);

  final Memory memory;
  final String tagSuffix;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            color: (memory.mMood?.color ?? Colors.grey).withOpacity(0.2),
            height: 50,
            width: (MediaQuery.of(context).size.width / 2) - 8,
            child: Center(
              child: Text(
                memory.mActivityList.isEmpty
                    ? 'No Activity'
                    : memory.mActivityList
                        .map((e) => e.activityName)
                        .toList()
                        .join(" | "),
              ),
            ),
          ),
          Container(
            color: (memory.mMood?.color ?? Colors.grey).withOpacity(0.2),
            height: 50,
            width: (MediaQuery.of(context).size.width / 2) - 4,
            child: Row(children: [
              CircleAvatar(
                backgroundColor: (memory.mMood?.color ?? Colors.grey),
                radius: 15,
              ),
              SizedBox(
                width: 20,
              ),
              Text(memory.mMood?.moodName ?? 'No Mood'.toUpperCase())
            ]),
          ),
        ],
      ),
    );
  }
}
