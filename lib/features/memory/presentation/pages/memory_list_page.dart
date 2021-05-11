import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:invert_colors/invert_colors.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mood_manager/core/constants/app_constants.dart';
import 'package:mood_manager/features/common/data/datasources/common_remote_data_source.dart';
import 'package:mood_manager/features/common/domain/entities/base_states.dart';
import 'package:mood_manager/features/common/domain/entities/media.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection_mapping.dart';
import 'package:mood_manager/features/common/presentation/widgets/empty_widget.dart';
import 'package:mood_manager/features/common/presentation/widgets/media_page_view.dart';
import 'package:mood_manager/features/memory/data/datasources/memory_remote_data_source.dart';
import 'package:mood_manager/features/memory/data/models/memory_collection_mapping_parse.dart';
import 'package:mood_manager/features/memory/data/models/memory_collection_parse.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:mood_manager/features/memory/domain/entities/memory_collection.dart';
import 'package:mood_manager/features/memory/presentation/bloc/memory_bloc.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:sliding_panel/sliding_panel.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

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

Widget wrapScrollTag({
  int index,
  Widget child,
  Color highlightColor,
  ScrollController controller,
}) =>
    AutoScrollTag(
      key: ValueKey(index),
      controller: controller,
      index: index,
      child: child,
      highlightColor: highlightColor.withOpacity(0.3),
    );

Future showNewMemoryCollectionDialog(BuildContext context) async {
  final TextEditingController _textFieldController = TextEditingController();
  return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Activity'),
              content: Container(
                height: 160,
                child: Column(
                  children: [
                    TextField(
                      controller: _textFieldController,
                      decoration: InputDecoration(
                        hintText: "eg.family",
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text('SUBMIT'),
                  onPressed: () {
                    if (_textFieldController.text.isNotEmpty) {
                      Navigator.of(context).pop(_textFieldController.text);
                    }
                  },
                )
              ],
            );
          },
        );
      });
}

// ignore: must_be_immutable
class MemoryListPage extends StatefulWidget {
  final Map<dynamic, dynamic> arguments;
  DateTime calendarSelectedDate;
  List<Memory> memoryList;
  String listType;
  String title;
  String uniqueKey;
  MemoryCollection memoryCollection;
  Media media;
  String memoryId;
  Function saveCallback;
  BuildContext appContext;
  MemoryListPage({Key key, this.arguments}) : super(key: key) {
    if (arguments != null) {
      this.calendarSelectedDate = this.arguments['selectedDate'];
      this.memoryList = this.arguments['memoryList'];
      this.listType = this.arguments['listType'];
      this.title = this.arguments['title'];
      this.memoryCollection = this.arguments['collection'];
      this.media = this.arguments['media'];
      this.memoryId = this.arguments['memoryId'];
      this.saveCallback = this.arguments['saveCallback'];
      this.appContext = this.arguments['context'];
    }
  }

  @override
  _MemoryListPageState createState() => _MemoryListPageState();
}

class _MemoryListPageState extends State<MemoryListPage> {
  List<Memory> memoryList = [];
  Map<DateTime, List<Memory>> memoryListMapByDate = {};
  Map<String, Future<List<MediaCollectionMapping>>>
      mediaCollectionListMapByMemory = {};
  MemoryBloc _memoryBloc;
  List<DateTime> dateKeys = [];
  AutoScrollController autoScrollController;
  MapEntry<String, Memory> lastSavedWithActionType;
  //ProgressDialog pr;
  final Uuid uuid = sl<Uuid>();
  String uniqueKey;
  bool _isFabVisible = true;
  CommonRemoteDataSource commonRemoteDataSource;
  MemoryRemoteDataSource memoryRemoteDataSource;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    /*pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);*/
    autoScrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);
    uniqueKey = uuid.v1();
    commonRemoteDataSource = sl<CommonRemoteDataSource>();
    memoryRemoteDataSource = sl<MemoryRemoteDataSource>();
    initializeList();
    //_memoryBloc.listen(progressDialogListener);
  }

  /*progressDialogListener(state) async {
    if (state is MemoryProcessing) {
      await pr.show();
    } else if (state is MemoryCompleted) {
      await pr.hide();
    }
  }*/

  void initializeList() async {
    if (widget.listType == 'ARCHIVE') {
      _memoryBloc = _memoryBloc ?? sl<MemoryBloc>();
      _isFabVisible = false;
      _memoryBloc.add(GetArchiveMemoryListEvent());
    } else if (widget.listType == 'COLLECTION') {
      _memoryBloc = _memoryBloc ?? sl<MemoryBloc>();
      _memoryBloc.add(GetMemoryListByCollectionEvent(widget.memoryCollection));
      _isFabVisible = false;
    } else if (widget.memoryList != null) {
      memoryList = widget.memoryList;
      memoryListMapByDate = subListMapByDate(memoryList);
      dateKeys = memoryListMapByDate.keys.toList();
      mediaCollectionListMapByMemory = getMediaCollectionMap();
      _memoryBloc = _memoryBloc ?? sl<MemoryBloc>();
    } else if (widget.media != null) {
      _memoryBloc = _memoryBloc ?? sl<MemoryBloc>();
      _memoryBloc.add(GetMemoryListByMediaEvent(widget.media));
    } else if (widget.memoryId != null) {
      _memoryBloc = _memoryBloc ?? sl<MemoryBloc>();
      _memoryBloc.add(GetSingleMemoryByIdEvent(widget.memoryId));
    } else {
      _memoryBloc = _memoryBloc ?? BlocProvider.of<MemoryBloc>(context);
      _memoryBloc.add(GetMemoryListEvent());
    }
    if ((widget.arguments ?? {})['memoryList'] == null) {}
  }

  _scrollToIndex(int index) {
    autoScrollController.scrollToIndex(index,
        preferPosition: AutoScrollPosition.middle);
    autoScrollController.highlight(index,
        highlightDuration: Duration(seconds: 2));
  }

  Future<void> deleteMemory(memory) async {
    memory.isActive = false;
    _memoryBloc.add(SaveMemoryEvent(
      memory: memory,
      mediaCollectionMappingList:
          await mediaCollectionListMapByMemory[memory.id],
    ));
  }

  Future<void> archiveMemory(memory) async {
    _memoryBloc.add(ArchiveMemoryEvent(
        memory: memory,
        mediaCollectionMappingList:
            await mediaCollectionListMapByMemory[memory.id]));
  }

  Future<void> addToCollection(Memory memory) async {
    MemoryCollection result;
    memoryRemoteDataSource.getMemoryCollectionList().then((value) async {
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

  removeFromCollection(Memory memory) async {
    _memoryBloc.add(
      AddMemoryToCollectionEvent(
        MemoryCollectionMappingParse(
          memory: memory,
          memoryCollection: widget.memoryCollection
              .decrementMemoryCount()
              .removeColor(memory.mMood.color),
          isActive: false,
        ),
      ),
    );
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
          final collectionName = await showNewMemoryCollectionDialog(context);
          final newMemoryCollection = MemoryCollectionParse(
              name: collectionName, user: await ParseUser.currentUser());
          Navigator.of(context).pop(newMemoryCollection);
        },
      ),
      Divider(
        thickness: 1,
        height: 1,
      ),
      ...value
          .where((element) =>
              widget.listType != 'COLLECTION' ||
              widget.memoryCollection != element)
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
          title: Text(widget.title ?? "Your memories"),
        ),
        floatingActionButton: Visibility(
          visible: _isFabVisible,
          child: FloatingActionButton(
            onPressed: navigateToMemoryForm,
            child: Icon(
              Icons.add,
            ),
            heroTag: uniqueKey,
          ),
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
                  handleLoader(state, context);
                  if (state is MemoryListLoaded) {
                    //Loader.hide();
                    memoryList = state.memoryList;
                    widget.memoryCollection =
                        widget.memoryCollection ?? state.memoryCollection;
                    memoryListMapByDate = subListMapByDate(memoryList);
                    dateKeys = memoryListMapByDate.keys.toList();
                    mediaCollectionListMapByMemory = getMediaCollectionMap();
                  } else if (state is AddedToMemoryCollection) {
                    //Loader.hide();
                    widget.saveCallback?.call();
                    if (state.memoryCollectionMapping.memoryCollection.id ==
                        widget.memoryCollection?.id) {
                      initializeList();
                    }
                  } else if (state is MemorySaved) {
                    //Loader.hide();
                    initializeList();
                    //Navigator.of(context).pop(MapEntry('U', state.memory));
                    // widget.saveCallback?.call();
                  }
                },
                builder: (context, state) {
                  /*if (state is MemoryProcessing) {
                    return EmptyWidget();
                  }*/
                  if (lastSavedWithActionType != null) {
                    final scrollIndex = (memoryList ?? []).indexWhere(
                        (element) =>
                            element.id == lastSavedWithActionType.value.id);
                    _scrollToIndex(scrollIndex);
                    //_scrollToIndex(scrollIndex);
                    /*WidgetsBinding.instance.addPostFrameCallback(
                        (_) => _scrollToIndex(scrollIndex));*/
                    lastSavedWithActionType = null;
                  }
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.builder(
                      controller: autoScrollController,
                      physics: BouncingScrollPhysics(),
                      itemCount: (memoryListMapByDate ?? {}).length + 1,
                      itemBuilder: (context, index) {
                        if (index == (memoryListMapByDate ?? {}).length) {
                          return SizedBox(
                              height: (memoryListMapByDate ?? {}).length <= 1
                                  ? 500
                                  : 400);
                        }
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
                                final mediaCount = memory.mediaCollectionList
                                    .fold(
                                        0,
                                        (previousValue, element) =>
                                            element.mediaCount + previousValue);
                                return wrapScrollTag(
                                    controller: autoScrollController,
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
                                              listType: widget.listType,
                                              memory: memory,
                                              navigateToMemoryForm:
                                                  navigateToMemoryForm,
                                              deleteMemory: deleteMemory,
                                              archiveMemory: archiveMemory,
                                              addToCollection: addToCollection,
                                              removeFromCollection:
                                                  removeFromCollection),
                                          if (mediaCount > 0)
                                            FutureBuilder<
                                                List<MediaCollectionMapping>>(
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
                                                  navigateToMediaPageView:
                                                      (index) {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (context) {
                                                      return MediaPageView(
                                                        mediaCollectionList:
                                                            snapshot.data,
                                                        initialIndex: index,
                                                        saveMediaCollectionMappingList:
                                                            (mediaCollectionMappingList) {
                                                          _memoryBloc.add(
                                                              SaveMemoryEvent(
                                                            memory: memory,
                                                            mediaCollectionMappingList:
                                                                mediaCollectionMappingList,
                                                          ));
                                                        },
                                                      );
                                                    }));
                                                  },
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

  Map<String, Future<List<MediaCollectionMapping>>> getMediaCollectionMap() {
    return Map.fromEntries(memoryList.map((e) => MapEntry(
        e.id,
        sl<CommonRemoteDataSource>().getMediaCollectionMappingByCollectionList(
            e.mediaCollectionList))));
  }

  Future<void> _refresh() {
    initializeList();
    return Future.value();
  }

  void navigateToMemoryForm({Memory memory}) async {
    final result = await Navigator.of(context)
        .pushNamed('/memory/add', arguments: {'memory': memory});
    if (result != null) {
      lastSavedWithActionType = result;
      initializeList();
    }
    //initializeList();
  }

  @override
  void dispose() {
    _memoryBloc?.close();
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
        Flexible(
          child: Text(
            (memory.title ?? '') + '\n' + memory.note,
            overflow: TextOverflow.clip,
          ),
        ),
      ]),
    );
  }
}

class MemoryMediaGrid extends StatelessWidget {
  final List<MediaCollectionMapping> mediaCollectionList;
  final Function navigateToMediaPageView;
  const MemoryMediaGrid(
      {Key key, this.mediaCollectionList, this.navigateToMediaPageView})
      : super(key: key);

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
                    navigateToMediaPageView?.call(index);
                  },
                  child: Hero(
                    tag: mediaCollectionList[index].media.tag,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                      child: Image(
                        image:
                            mediaCollectionList[index].media.thumbnailProvider,
                        fit: BoxFit.cover,
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

  final List<MediaCollectionMapping> mediaCollectionList;

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
                      initialIndex: index,
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
    @required this.navigateToMemoryForm,
    @required this.deleteMemory,
    @required this.archiveMemory,
    @required this.addToCollection,
    this.removeFromCollection,
    this.listType,
  }) : super(key: key);

  final Memory memory;
  final Function navigateToMemoryForm;
  final Function deleteMemory;
  final Function archiveMemory;
  final Function addToCollection;
  final Function removeFromCollection;
  final String listType;

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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  memory.mMood != null
                      ? Stack(children: <Widget>[
                          Positioned.fill(
                            child: CircleAvatar(
                              // child: Text(value.moodName),
                              backgroundColor: memory.mMood.color,
                              radius: 35, // Color
                            ),
                          ),
                          InvertColors(
                            child: ImageIcon(
                              AssetImage('assets/${memory.mMood.moodName}.png'),
                              size: 35,
                              //color: color,
                            ),
                          ),
                        ])
                      : CircleAvatar(
                          backgroundColor: Colors.grey,
                          radius: 15,
                        ),
                  SizedBox(
                    width: 20,
                  ),
                  Text(memory.mMood?.moodName ?? 'No Mood'.toUpperCase()),
                ]),
                Container(
                  child: PopupMenuButton(
                    elevation: 3.2,
                    onCanceled: () {
                      print('You have not chossed anything');
                    },
                    tooltip: 'This is tooltip',
                    onSelected: (fn) => fn(),
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem(
                          child: Text('Edit'),
                          value: () {
                            navigateToMemoryForm(memory: memory);
                          },
                        ),
                        if (listType == null)
                          PopupMenuItem(
                              child: Text('Delete'),
                              value: () {
                                deleteMemory(memory);
                              }),
                        if (listType != 'ARCHIVE')
                          PopupMenuItem(
                            child: Text('Archive'),
                            value: () {
                              archiveMemory(memory);
                            },
                          ),
                        if (listType != 'COLLECTION')
                          PopupMenuItem(
                            child: Text('Add to collection'),
                            value: () {
                              addToCollection(memory);
                            },
                          ),
                        if (listType == 'COLLECTION')
                          PopupMenuItem(
                            child: Text('Add to other collection'),
                            value: () {
                              addToCollection(memory);
                            },
                          ),
                        if (listType == 'ARCHIVE')
                          PopupMenuItem(
                            child: Text('Remove from archive'),
                            value: () {
                              removeFromCollection(memory);
                            },
                          ),
                        if (listType == 'COLLECTION')
                          PopupMenuItem(
                            child: Text('Remove from collection'),
                            value: () {
                              removeFromCollection(memory);
                            },
                          )
                      ];
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
