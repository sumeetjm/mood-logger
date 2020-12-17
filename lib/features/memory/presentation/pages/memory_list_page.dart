import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mood_manager/core/constants/app_constants.dart';
import 'package:mood_manager/features/common/data/datasources/common_remote_data_source.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/common/presentation/widgets/empty_widget.dart';
import 'package:mood_manager/features/common/presentation/widgets/image_slider.dart';
import 'package:mood_manager/features/common/presentation/widgets/media_page_view.dart';
import 'package:mood_manager/features/common/presentation/widgets/memory_image_slider.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:mood_manager/features/memory/presentation/bloc/memory_bloc.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/widgets.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:intl/intl.dart';

class MemoryListPage extends StatefulWidget {
  final Map<dynamic, dynamic> arguments;
  MemoryListPage({Key key, this.arguments}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    _memoryBloc = sl<MemoryBloc>();
    _memoryBloc.add(GetMemoryListEvent());
    scrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);
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
              image: AssetImage("assets/grey_abstract_geometric_triangle.jpg"),
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
                mediaCollectionMap[memory.id] = sl<CommonRemoteDataSource>()
                    .getMediaCollectionByCollectionList(memory.collectionList);
              }
              mediaCollectionListMapByMemory = mediaCollectionMap;
            }
          },
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
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
                                DateFormat(AppConstants.HEADER_DATE_FORMAT)
                                    .format(dateKeys[index]),
                                style: TextStyle(
                                    color: Colors.grey[50],
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic),
                              )))),
                      content: Column(
                          children: memoryListDateWise
                              .map((memory) => _wrapScrollTag(
                                  index: memoryList.indexWhere(
                                      (element) => element.id == memory.id),
                                  highlightColor:
                                      (memory.mMood?.color ?? Colors.grey),
                                  child: Container(
                                    padding: EdgeInsets.all(2),
                                    child: Column(
                                      children: [
                                        Center(
                                            child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Text(
                                            DateFormat(DateFormat.HOUR_MINUTE)
                                                .format(memory.logDateTime),
                                          ),
                                        )),
                                        Card(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                color: (memory.mMood?.color ??
                                                        Colors.grey)
                                                    .withOpacity(0.2),
                                                height: 50,
                                                width: (MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2) -
                                                    8,
                                                child: Center(
                                                  child: Text(
                                                    memory.mActivityList.isEmpty
                                                        ? 'No Activity'
                                                        : memory.mActivityList
                                                            .map((e) =>
                                                                e.activityName)
                                                            .toList()
                                                            .join(" | "),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                color: (memory.mMood?.color ??
                                                        Colors.grey)
                                                    .withOpacity(0.2),
                                                height: 50,
                                                width: (MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2) -
                                                    4,
                                                child: Row(children: [
                                                  CircleAvatar(
                                                    backgroundColor:
                                                        (memory.mMood?.color ??
                                                            Colors.grey),
                                                    radius: 15,
                                                  ),
                                                  SizedBox(
                                                    width: 20,
                                                  ),
                                                  Text(memory.mMood?.moodName ??
                                                      'No Mood'.toUpperCase())
                                                ]),
                                              ),
                                            ],
                                          ),
                                        ),
                                        FutureBuilder<List<MediaCollection>>(
                                          future:
                                              mediaCollectionListMapByMemory[
                                                  memory.id],
                                          builder: (context, snapshot) {
                                            int mediaCount =
                                                memory.collectionList.fold(
                                                    0,
                                                    (previousValue, element) =>
                                                        element.mediaCount +
                                                        previousValue);
                                            if (!snapshot.hasData) {
                                              return Card(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(2.0),
                                                  child: GridView.count(
                                                    crossAxisCount:
                                                        mediaCount == 1 ? 1 : 2,
                                                    crossAxisSpacing: 1,
                                                    mainAxisSpacing: 1,
                                                    physics:
                                                        NeverScrollableScrollPhysics(), // to disable GridView's scrolling
                                                    shrinkWrap: true,
                                                    children: List.generate(
                                                      mediaCount >= 4
                                                          ? 4
                                                          : mediaCount,
                                                      (index) => Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          5)),
                                                          border: Border.all(
                                                              color: Colors
                                                                  .grey[400],
                                                              width: 1),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                                    gradient: new LinearGradient(
                                                                        colors: [
                                                                  Colors.white,
                                                                  Colors.grey,
                                                                ],
                                                                        stops: [
                                                                  0.0,
                                                                  1.0
                                                                ],
                                                                        begin: FractionalOffset
                                                                            .topCenter,
                                                                        end: FractionalOffset
                                                                            .bottomCenter,
                                                                        tileMode:
                                                                            TileMode.mirror)),
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
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                child: GridView.builder(
                                                  itemCount:
                                                      snapshot.data.length >= 4
                                                          ? 4
                                                          : snapshot
                                                              .data.length,
                                                  gridDelegate:
                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount:
                                                        snapshot.data.length ==
                                                                1
                                                            ? 1
                                                            : 2,
                                                    crossAxisSpacing: 1,
                                                    mainAxisSpacing: 1,
                                                  ),

                                                  itemBuilder:
                                                      (context, index) {
                                                    if (index == 3 &&
                                                        (snapshot.data.length -
                                                                3 >
                                                            1)) {
                                                      return Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          5)),
                                                          border: Border.all(
                                                              color: Colors
                                                                  .grey[400],
                                                              width: 1),
                                                        ),
                                                        child: Stack(
                                                          children: [
                                                            Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .push(MaterialPageRoute(builder:
                                                                            (context) {
                                                                      return MediaPageView(
                                                                        mediaCollectionList:
                                                                            snapshot.data,
                                                                        initialItem:
                                                                            snapshot.data[index],
                                                                      );
                                                                    }));
                                                                  },
                                                                  child:
                                                                      ColorFiltered(
                                                                          colorFilter: ColorFilter
                                                                              .mode(
                                                                            Colors.black.withOpacity(0.4),
                                                                            BlendMode.darken,
                                                                          ),
                                                                          child:
                                                                              Container(
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              border: Border.all(color: Colors.grey, width: 1),
                                                                            ),
                                                                            child:
                                                                                GridView.builder(
                                                                              physics: NeverScrollableScrollPhysics(),
                                                                              itemCount: snapshot.data.length - 3,
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
                                                                                    imageUrl: snapshot.data[newIndex].media.thumbnail.url,
                                                                                  ),
                                                                                );
                                                                              },
                                                                            ),
                                                                          )),
                                                                )),
                                                            Center(
                                                              child: Text(
                                                                (snapshot.data.length -
                                                                            3)
                                                                        .toString() +
                                                                    " more",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }
                                                    return Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    5)),
                                                        border: Border.all(
                                                            color: Colors
                                                                .grey[400],
                                                            width: 1),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            Navigator.of(
                                                                    context)
                                                                .push(MaterialPageRoute(
                                                                    builder:
                                                                        (context) {
                                                              return MediaPageView(
                                                                mediaCollectionList:
                                                                    snapshot
                                                                        .data,
                                                                initialItem:
                                                                    snapshot.data[
                                                                        index],
                                                              );
                                                            }));
                                                          },
                                                          child: Hero(
                                                            tag: snapshot
                                                                .data[index]
                                                                .media
                                                                .id,
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .grey,
                                                                    width: 1),
                                                              ),
                                                              child:
                                                                  CachedNetworkImage(
                                                                fit: BoxFit
                                                                    .cover,
                                                                imageUrl: snapshot
                                                                            .data
                                                                            .length ==
                                                                        1
                                                                    ? snapshot
                                                                        .data[
                                                                            index]
                                                                        .media
                                                                        .file
                                                                        .url
                                                                    : snapshot
                                                                        .data[
                                                                            index]
                                                                        .media
                                                                        .thumbnail
                                                                        .url,
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    new Icon(Icons
                                                                        .error),
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
                                        if ((memory.note ?? "").isNotEmpty)
                                          Container(
                                            padding: EdgeInsets.all(10),
                                            child: Row(children: [
                                              Text(memory.note),
                                            ]),
                                          ),
                                      ],
                                    ),
                                  )))
                              .toList()),
                    );
                  }),
            );
          },
        ),
      ),
    );
  }

  Future<void> _refresh() {
    _memoryBloc.add(GetMemoryListEvent());
    return Future.value();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _memoryBloc.close();
  }
}
