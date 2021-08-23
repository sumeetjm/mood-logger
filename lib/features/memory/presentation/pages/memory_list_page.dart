import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:invert_colors/invert_colors.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mood_manager/core/constants/app_constants.dart';
import 'package:mood_manager/core/util/color_util.dart';
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
import 'package:mood_manager/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:mood_manager/home.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:sliding_panel/sliding_panel.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:intl/intl.dart';
import 'package:tinycolor/tinycolor.dart';
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
      highlightColor: highlightColor.withOpacity(0.4),
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
                new TextButton(
                  child: new Text('SUBMIT'),
                  onPressed: () {
                    if (_textFieldController.text.isNotEmpty) {
                      Navigator.of(appNavigatorContext(context))
                          .pop(_textFieldController.text);
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
  ValueChanged<MediaCollectionMapping> addToCollectionCallback;
  Function addToMemoryCollectionCallback;
  Function onChanged;
  bool displayAppBar;
  bool showMenuButton;
  MemoryListPage(
      {Key key,
      this.arguments,
      this.displayAppBar = true,
      this.showMenuButton = true})
      : super(key: key) {
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
      this.addToCollectionCallback = this.arguments['addToCollectionCallback'];
      this.addToMemoryCollectionCallback =
          this.arguments['addToMemoryCollectionCallback'];
      this.onChanged = this.arguments['onChanged'];
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
  ProfileBloc _profileBloc;
  List<DateTime> dateKeys = [];
  AutoScrollController autoScrollController;
  MapEntry<String, Memory> lastSavedWithActionType;
  //ProgressDialog pr;
  final Uuid uuid = sl<Uuid>();
  String uniqueKey;
  CommonRemoteDataSource commonRemoteDataSource;
  MemoryRemoteDataSource memoryRemoteDataSource;

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
    initializeList(null);
    _profileBloc = BlocProvider.of<ProfileBloc>(context);
    //_memoryBloc.listen(progressDialogListener);
  }

  /*progressDialogListener(state) async {
    if (state is MemoryProcessing) {
      await pr.show();
    } else if (state is MemoryCompleted) {
      await pr.hide();
    }
  }*/

  void initializeList(String scrollToItemId) async {
    if (widget.listType == 'ARCHIVE') {
      _memoryBloc = _memoryBloc ?? sl<MemoryBloc>();
      _memoryBloc.add(GetArchiveMemoryListEvent());
    } else if (widget.listType == 'COLLECTION') {
      _memoryBloc = _memoryBloc ?? sl<MemoryBloc>();
      _memoryBloc.add(GetMemoryListByCollectionEvent(widget.memoryCollection));
    } else if (widget.memoryList != null) {
      memoryList = widget.memoryList;
      memoryListMapByDate = subListMapByDate(memoryList);
      dateKeys = memoryListMapByDate.keys.toList();
      commonRemoteDataSource.isConnected().then((value) {
        if (value) {
          mediaCollectionListMapByMemory = getMediaCollectionMap();
        } else {
          Fluttertoast.showToast(
              gravity: ToastGravity.TOP,
              msg: 'Unable to connect',
              backgroundColor: Colors.red);
        }
      });

      _memoryBloc = _memoryBloc ?? sl<MemoryBloc>();
    } else if (widget.media != null) {
      _memoryBloc = _memoryBloc ?? sl<MemoryBloc>();
      _memoryBloc.add(GetMemoryListByMediaEvent(widget.media));
    } else if (widget.memoryId != null) {
      _memoryBloc = _memoryBloc ?? sl<MemoryBloc>();
      _memoryBloc.add(GetSingleMemoryByIdEvent(widget.memoryId));
    } else {
      _memoryBloc = _memoryBloc ?? BlocProvider.of<MemoryBloc>(context);
      _memoryBloc.add(GetMemoryListEvent(scrollToItemId: scrollToItemId));
    }
    if ((widget.arguments ?? {})['memoryList'] == null) {}
  }

  _scrollToIndex(int index) {
    autoScrollController.scrollToIndex(index,
        preferPosition: AutoScrollPosition.middle);
    autoScrollController.highlight(index,
        highlightDuration: Duration(seconds: 4));
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
        context: appNavigatorContext(context),
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
        appBar: widget.displayAppBar
            ? AppBar(
                leading: widget.showMenuButton
                    ? IconButton(
                        icon: Icon(Icons.menu),
                        onPressed: () {
                          Provider.of<GlobalKey<ScaffoldState>>(context,
                                  listen: false)
                              .currentState
                              .openDrawer();
                        },
                      )
                    : null,
                centerTitle: true,
                title: Text(
                  "Memories",
                ),
              )
            : PreferredSize(
                preferredSize: Size.fromHeight(0.0),
                child: Container(),
              ),
        body: Container(
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
                    if (state.scrollToItemId != null) {
                      final scrollIndex = (memoryList ?? []).indexWhere(
                          (element) => element.id == state.scrollToItemId);
                      _scrollToIndex(scrollIndex);
                    }
                  } else if (state is AddedToMemoryCollection) {
                    //Loader.hide();
                    Fluttertoast.showToast(
                        gravity: ToastGravity.TOP,
                        msg:
                            '${state.memoryCollectionMapping.isActive ? 'Added to' : 'Removed from'} ${state.memoryCollectionMapping.memoryCollection.name == 'ARCHIVE' ? state.memoryCollectionMapping.memoryCollection.name.toLowerCase() : state.memoryCollectionMapping.memoryCollection.name}',
                        backgroundColor: Colors.green);
                    widget.saveCallback?.call();
                    if (state.memoryCollectionMapping.memoryCollection.id ==
                            widget.memoryCollection?.id ||
                        state.memoryCollectionMapping.memoryCollection.name ==
                            'ARCHIVE') {
                      widget.addToMemoryCollectionCallback?.call();
                      initializeList(null);
                    }
                  } else if (state is MemorySaved) {
                    if (state.memory.isActive) {
                      Fluttertoast.showToast(
                          gravity: ToastGravity.TOP,
                          msg: 'Memory saved successfully',
                          backgroundColor: Colors.green);
                    } else {
                      Fluttertoast.showToast(
                          gravity: ToastGravity.TOP,
                          msg: 'Memory deleted successfully',
                          backgroundColor: Colors.green);
                    }
                    //Loader.hide();
                    initializeList(state.memory.id);
                    //Navigator.of(context).pop(MapEntry('U', state.memory));
                    // widget.saveCallback?.call();
                  } else if (state is MemoryListError) {
                    Fluttertoast.showToast(
                        gravity: ToastGravity.TOP,
                        msg: state.message,
                        backgroundColor: Colors.red);
                  }
                },
                builder: (context, state) {
                  /*if (state is MemoryProcessing) {
                    return EmptyWidget();
                  }*/
                  if ((memoryListMapByDate ?? {}).length == 0 &&
                      (state is Completed)) {
                    if (!(widget.listType != 'ARCHIVE' &&
                        widget.listType != 'COLLECTION')) {
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Center(
                            child: Text(
                          'No memories yet',
                          style: TextStyle(fontSize: 20),
                        )),
                      );
                    }
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Center(
                              child: Text(
                            'No memories yet',
                            style: TextStyle(fontSize: 20),
                          )),
                        ),
                        Container(
                          height: 75,
                          padding: EdgeInsets.all(8.0),
                          child: TextButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Theme.of(context).primaryColor),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ))),
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
                            onPressed: navigateToMemoryForm,
                          ),
                        ),
                      ],
                    );
                  }
                  return RefreshIndicator(
                      onRefresh: _refresh,
                      child: AnimationLimiter(
                        child: ListView.builder(
                          controller: autoScrollController,
                          physics: BouncingScrollPhysics(),
                          itemCount: (memoryListMapByDate ?? {}).length + 1,
                          itemBuilder: (context, index) {
                            if (index == (memoryListMapByDate ?? {}).length) {
                              return SizedBox(
                                  height:
                                      (memoryListMapByDate ?? {}).length <= 1
                                          ? 500
                                          : 400);
                            }
                            final memoryListDateWise =
                                memoryListMapByDate[dateKeys[index]];
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 500),
                              child: SlideAnimation(
                                horizontalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: StickyHeader(
                                      header: Center(
                                          child: Container(
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: ColorUtil.mix(
                                                        memoryListDateWise
                                                            .map((e) =>
                                                                e.mMood
                                                                    ?.color ??
                                                                Colors.grey)
                                                            .toList())
                                                    .withOpacity(0.8),
                                              ),
                                              child: Center(
                                                  child: Text(
                                                DateFormat(AppConstants
                                                        .HEADER_DATE_FORMAT)
                                                    .format(dateKeys[index]),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    fontStyle:
                                                        FontStyle.italic),
                                              )))),
                                      content: AnimationLimiter(
                                        child: ListView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: memoryListDateWise.length,
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            final memory =
                                                memoryListDateWise[index];
                                            final mediaCount =
                                                memory.mediaCollectionList.fold(
                                                    0,
                                                    (previousValue, element) =>
                                                        (element.mediaCount ??
                                                            0) +
                                                        previousValue);
                                            return AnimationConfiguration
                                                .staggeredList(
                                              position: index,
                                              duration: const Duration(
                                                  milliseconds: 500),
                                              child: SlideAnimation(
                                                horizontalOffset: 50.0,
                                                child: FadeInAnimation(
                                                  child: wrapScrollTag(
                                                      controller:
                                                          autoScrollController,
                                                      index:
                                                          memoryList.indexWhere(
                                                              (element) =>
                                                                  element.id ==
                                                                  memory.id),
                                                      highlightColor: (memory
                                                              .mMood?.color ??
                                                          Colors.grey),
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.all(2),
                                                        child: Column(
                                                          children: [
                                                            MemoryTime(
                                                                memory: memory),
                                                            MemoryActivityAndMood(
                                                                listType: widget
                                                                    .listType,
                                                                memory: memory,
                                                                navigateToMemoryForm:
                                                                    navigateToMemoryForm,
                                                                deleteMemory:
                                                                    deleteMemory,
                                                                archiveMemory:
                                                                    archiveMemory,
                                                                addToCollection:
                                                                    addToCollection,
                                                                removeFromCollection:
                                                                    removeFromCollection),
                                                            if (mediaCount > 0)
                                                              FutureBuilder<
                                                                  List<
                                                                      MediaCollectionMapping>>(
                                                                future:
                                                                    mediaCollectionListMapByMemory[
                                                                        memory
                                                                            .id],
                                                                builder: (context,
                                                                    snapshot) {
                                                                  if (!snapshot
                                                                      .hasData) {
                                                                    return GridPlaceholder(
                                                                        mediaCount:
                                                                            mediaCount);
                                                                  }
                                                                  if ((snapshot
                                                                              .data ??
                                                                          [])
                                                                      .isEmpty) {
                                                                    return EmptyWidget();
                                                                  }
                                                                  return MemoryMediaGrid(
                                                                    tagSuffix:
                                                                        'LIST',
                                                                    mediaCollectionList:
                                                                        snapshot
                                                                            .data,
                                                                    navigateToMediaPageView:
                                                                        (index) {
                                                                      Navigator.of(appNavigatorContext(
                                                                              context))
                                                                          .push(MaterialPageRoute(builder:
                                                                              (context) {
                                                                        return MediaPageView(
                                                                          tagSuffix:
                                                                              'LIST',
                                                                          mediaCollectionList:
                                                                              snapshot.data,
                                                                          initialIndex:
                                                                              index,
                                                                          saveMediaCollectionMappingList:
                                                                              (mediaCollectionMappingList) {
                                                                            _memoryBloc.add(SaveMemoryEvent(
                                                                              memory: memory,
                                                                              mediaCollectionMappingList: mediaCollectionMappingList,
                                                                            ));
                                                                          },
                                                                          setAsProfilePicCallback:
                                                                              (value) {
                                                                            _profileBloc.add(SaveProfilePictureEvent(null,
                                                                                null,
                                                                                media: value));
                                                                          },
                                                                          goToMemoryCallback:
                                                                              (value) {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          addToCollectionCallback:
                                                                              widget.addToCollectionCallback,
                                                                        );
                                                                      }));
                                                                    },
                                                                  );
                                                                },
                                                              ),
                                                            if ((memory.note ??
                                                                    "")
                                                                .isNotEmpty)
                                                              MemoryNote(
                                                                  memory:
                                                                      memory),
                                                          ],
                                                        ),
                                                      )),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      )),
                                ),
                              ),
                            );
                          },
                        ),
                      ));
                })));
  }

  Map<String, Future<List<MediaCollectionMapping>>> getMediaCollectionMap() {
    return Map.fromEntries(memoryList.map((e) => MapEntry(
        e.id,
        commonRemoteDataSource.getMediaCollectionMappingByCollectionList(
            e.mediaCollectionList))));
  }

  Future<void> _refresh() {
    initializeList(null);
    return Future.value();
  }

  void navigateToMemoryForm({Memory memory}) async {
    final result = await Navigator.of(appNavigatorContext(context))
        .pushNamed('/memory/add', arguments: {'memory': memory});
    if (result != null) {
      if (widget.memoryCollection != null) {
        await memoryRemoteDataSource.saveMemoryCount(widget.memoryCollection);
      }
      widget.onChanged?.call();
      lastSavedWithActionType = result;
      initializeList(null);
    }
    //initializeList();
  }

  @override
  void dispose() {
    _memoryBloc?.close();
    super.dispose();
  }

  _scrollTo() {
    if (lastSavedWithActionType != null) {
      final scrollIndex = (memoryList ?? []).indexWhere(
          (element) => element.id == lastSavedWithActionType.value.id);
      _scrollToIndex(scrollIndex);
      lastSavedWithActionType = null;
    }
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (memory.title ?? ''),
                overflow: TextOverflow.clip,
                style: TextStyle(
                    color: TinyColor(memory?.mMood?.color ?? Colors.black)
                        .darken(30)
                        .color,
                    fontSize: 15),
              ),
              Text(
                (memory.note ?? ''),
                overflow: TextOverflow.clip,
                style: TextStyle(
                    color: TinyColor(Colors.grey).darken(30).color,
                    fontSize: 15),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

class MemoryMediaGrid extends StatelessWidget {
  final List<MediaCollectionMapping> mediaCollectionList;
  final Function navigateToMediaPageView;
  final String tagSuffix;
  const MemoryMediaGrid(
      {Key key,
      this.mediaCollectionList,
      this.navigateToMediaPageView,
      this.tagSuffix = ""})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: AnimationLimiter(
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
              return AnimationConfiguration.staggeredGrid(
                  columnCount: 2,
                  position: index,
                  duration: const Duration(milliseconds: 500),
                  child: ScaleAnimation(
                      child: FadeInAnimation(
                          child: MemoryMiniGrid(
                              mediaCollectionList: mediaCollectionList,
                              index: index,
                              navigateToMediaView: navigateToMediaPageView))));
            }
            return AnimationConfiguration.staggeredGrid(
                columnCount: 2,
                position: index,
                duration: const Duration(milliseconds: 500),
                child: ScaleAnimation(
                    child: FadeInAnimation(
                        child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: GestureDetector(
                    onTap: () {
                      navigateToMediaPageView?.call(index);
                    },
                    child: Hero(
                      tag: mediaCollectionList[index]
                          .media
                          .tag(suffix: tagSuffix),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1),
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 2,
                                  color: TinyColor(ColorUtil.mix([
                                    mediaCollectionList[index]
                                            .media
                                            .dominantColor ??
                                        Colors.grey
                                  ])).darken(30).color,
                                  spreadRadius: 1,
                                  offset: Offset(1, 1))
                            ]),
                        child: Image(
                          image: mediaCollectionList[index]
                              .media
                              .thumbnailProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ))));
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
  final Function navigateToMediaView;
  MemoryMiniGrid({
    Key key,
    @required this.mediaCollectionList,
    this.navigateToMediaView,
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
              padding: const EdgeInsets.all(2),
              child: GestureDetector(
                onTap: () {
                  navigateToMediaView?.call(index);
                },
                child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.5),
                      BlendMode.color,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                      child: AnimationLimiter(
                        child: GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: mediaCollectionList.length - 3,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 2,
                          ),
                          itemBuilder: (context, index) {
                            final newIndex = index + 3;
                            return AnimationConfiguration.staggeredGrid(
                                columnCount: 2,
                                position: index,
                                duration: const Duration(milliseconds: 500),
                                child: ScaleAnimation(
                                    child: FadeInAnimation(
                                        child: Container(
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl: mediaCollectionList[newIndex]
                                        .media
                                        .thumbnail
                                        .url,
                                  ),
                                ))));
                          },
                        ),
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
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: AnimationLimiter(
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
          itemBuilder: (context, index) => AnimationConfiguration.staggeredGrid(
              columnCount: 2,
              position: index,
              duration: const Duration(milliseconds: 500),
              child: ScaleAnimation(
                  child: FadeInAnimation(
                      child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Container(
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 2,
                            color: Colors.grey,
                            spreadRadius: 1,
                            offset: Offset(1, 1))
                      ],
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
              )))),
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: TinyColor((memory.mMood?.color ?? Colors.grey).withOpacity(0.5))
            .lighten(15)
            .color,
        boxShadow: [
          BoxShadow(
            color:
                TinyColor((memory.mMood?.color ?? Colors.grey).withOpacity(0.1))
                    .darken(15)
                    .color,
            blurRadius: 10.0,
            spreadRadius: 2.0,
          ), //BoxShadow
          BoxShadow(
            color:
                TinyColor((memory.mMood?.color ?? Colors.grey).withOpacity(0.1))
                    .darken(5)
                    .color,
            offset: const Offset(0.0, 0.0),
            blurRadius: 0.0,
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            //color: (memory.mMood?.color ?? Colors.grey).withOpacity(0.2),
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
            // color: (memory.mMood?.color ?? Colors.grey).withOpacity(0.2),
            height: 50,
            width: (MediaQuery.of(context).size.width / 2) - 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                memory.mMood != null
                    ? Stack(children: <Widget>[
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: TinyColor(memory.mMood.color)
                                      .lighten(10)
                                      .color,
                                  blurRadius: 2,
                                  spreadRadius: 2,
                                ), //BoxShadow
                              ],
                            ),
                            child: CircleAvatar(
                              // child: Text(value.moodName),
                              backgroundColor: memory.mMood.color,
                              radius: 35,
                              // Color
                            ),
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
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: TinyColor(Colors.grey).lighten(10).color,
                              blurRadius: 2,
                              spreadRadius: 2,
                            ), //BoxShadow
                          ],
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.grey,
                          radius: 15,
                        ),
                      ),
                Text(memory.mMood?.moodName ?? 'No Mood'.toUpperCase()),
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
