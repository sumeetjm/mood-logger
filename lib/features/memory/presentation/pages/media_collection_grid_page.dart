import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mood_manager/features/common/data/models/media_collection_parse.dart';
import 'package:mood_manager/features/common/domain/entities/base_states.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection_mapping.dart';
import 'package:mood_manager/features/common/presentation/widgets/empty_widget.dart';
import 'package:mood_manager/features/memory/presentation/bloc/memory_bloc.dart';
import 'package:mood_manager/features/memory/presentation/pages/memory_list_page.dart';
import 'package:mood_manager/features/memory/presentation/pages/media_wall_layout.dart';
import 'package:mood_manager/features/memory/presentation/widgets/shadow_text.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:uuid/uuid.dart';
import 'package:mood_manager/features/common/data/datasources/common_remote_data_source.dart';
import 'package:mood_manager/home.dart';

// ignore: must_be_immutable
class MediaCollectionGridPage extends StatefulWidget {
  String title;
  Map<String, dynamic> arguments;

  MediaCollectionGridPage({
    Key key,
    this.arguments = const {},
  }) : super(key: key);
  @override
  _MediaCollectionGridPageState createState() =>
      _MediaCollectionGridPageState();
}

class _MediaCollectionGridPageState extends State<MediaCollectionGridPage> {
  final Uuid uuid = sl<Uuid>();
  String uniqueKey;
  List<MediaCollection> mediaCollectionList = [];
  Map<String, Future<List<MediaCollectionMapping>>>
      mediaCollectionListMapByCollectionId = {};
  MemoryBloc _memoryBloc;
  AutoScrollController scrollController;
  CommonRemoteDataSource commonRemoteDataSource;

  @override
  void initState() {
    _memoryBloc = sl<MemoryBloc>();
    _memoryBloc.add(GetMediaCollectionListEvent(
        skipEmpty: widget.arguments['selectMode'] ?? false,
        mediaType: widget.arguments['mediaType']));
    scrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);
    commonRemoteDataSource = sl<CommonRemoteDataSource>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ??
            '${widget.arguments['mediaType'] == null ? 'Photos & Videos' : (widget.arguments['mediaType'] == 'PHOTO' ? 'Photos' : 'Videos')}'),
        actions: [
          if (widget.arguments['selectMode'] ?? false)
            IconButton(
                icon: Icon(Icons.close_rounded),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
        ],
      ),
      body: BlocConsumer<MemoryBloc, MemoryState>(
          listener: (context, state) {
            if (state is MediaCollectionListLoaded) {
              mediaCollectionList = state.mediaCollectionList;
              /*final Map<String, Future<List<MediaCollectionMapping>>>
                  mediaCollectionMap = {};
              commonRemoteDataSource.isConnected().then((isConnected) {
                if (isConnected) {
                  for (final mediaCollection in mediaCollectionList) {
                    mediaCollectionMap[
                            mediaCollection.id ?? mediaCollection.code] =
                        commonRemoteDataSource
                            .getMediaCollectionMappingByCollection(
                                mediaCollection,
                                limit: 4);
                  }
                  mediaCollectionListMapByCollectionId = mediaCollectionMap;
                } else {
                  Fluttertoast.showToast(
                      gravity: ToastGravity.TOP,
                      msg: 'Unable to connect',
                      backgroundColor: Colors.red);
                }
              });*/
            } else if (state is MemoryListError) {
              Fluttertoast.showToast(
                  gravity: ToastGravity.TOP,
                  msg: state.message,
                  backgroundColor: Colors.red);
            }
            handleLoader(state, context);
          },
          cubit: _memoryBloc,
          builder: (context, state) {
            if (state is MediaCollectionListLoaded) {
              return AnimationLimiter(
                child: GridView.builder(
                  itemCount: (widget.arguments['selectMode'] ?? false)
                      ? mediaCollectionList.length
                      : (mediaCollectionList.length + 1),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemBuilder: (context, index) {
                    if (index == mediaCollectionList.length) {
                      return AnimationConfiguration.staggeredGrid(
                          columnCount: 2,
                          position: index,
                          duration: const Duration(milliseconds: 500),
                          child: ScaleAnimation(
                              child: FadeInAnimation(
                                  child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1),
                            ),
                            child: Stack(
                              children: [
                                GridPlaceholder(
                                  mediaCount: 1,
                                ),
                                Center(
                                  child: ShadowText(
                                    '+ New collection',
                                    shadowColor: Theme.of(context).primaryColor,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final newCollection =
                                        await showNewMediaCollectionDialog(
                                            context);
                                    if (newCollection != null) {
                                      await EasyLoading.show(
                                          status: "Loading...",
                                          maskType: EasyLoadingMaskType.black);
                                      final MediaCollection newMediaCollection =
                                          await commonRemoteDataSource
                                              .saveMediaCollection(
                                                  MediaCollectionParse(
                                        code: uuid.v1(),
                                        mediaType: 'PHOTO',
                                        module: 'CUSTOM',
                                        name: newCollection,
                                        user: await ParseUser.currentUser(),
                                      ));
                                      EasyLoading.dismiss();
                                      setState(() {
                                        mediaCollectionList
                                            .add(newMediaCollection);
                                      });
                                    }
                                  },
                                  child: Container(color: Colors.transparent),
                                )
                              ],
                            ),
                          ))));
                    }
                    return AnimationConfiguration.staggeredGrid(
                        columnCount: 2,
                        position: index,
                        duration: const Duration(milliseconds: 500),
                        child: ScaleAnimation(
                            child: FadeInAnimation(
                                child: FutureBuilder<
                                        List<MediaCollectionMapping>>(
                                    future: commonRemoteDataSource
                                        .getMediaCollectionMappingByCollection(
                                            mediaCollectionList[index],
                                            limit: 4,
                                            mediaType:
                                                widget.arguments['mediaType']),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        int count = 0;
                                        if (widget.arguments['mediaType'] ==
                                            null) {
                                          count = mediaCollectionList[index]
                                                  .mediaCount ??
                                              0;
                                        } else if (widget
                                                .arguments['mediaType'] ==
                                            'PHOTO') {
                                          count = mediaCollectionList[index]
                                                  .imageCount ??
                                              0;
                                        } else if (widget
                                                .arguments['mediaType'] ==
                                            'VIDEO') {
                                          count = mediaCollectionList[index]
                                                  .videoCount ??
                                              0;
                                        }

                                        final photoCollectionTitle =
                                            mediaCollectionList[index].name +
                                                (mediaCollectionList[index]
                                                            .mediaCount ==
                                                        null
                                                    ? ''
                                                    : '(' +
                                                        count.toString() +
                                                        ')');
                                        return Stack(
                                          children: [
                                            ColorFiltered(
                                              colorFilter: ColorFilter.mode(
                                                  (mediaCollectionList[index]
                                                              .averageMediaColor ??
                                                          Colors.grey)
                                                      .withOpacity(0.2),
                                                  BlendMode.darken),
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.grey,
                                                        width: 1),
                                                  ),
                                                  child: snapshot.data.isEmpty
                                                      ? GridPlaceholder(
                                                          mediaCount: 1,
                                                        )
                                                      : Stack(
                                                          children: [
                                                            ImageFiltered(
                                                                imageFilter:
                                                                    ImageFilter.blur(
                                                                        sigmaX:
                                                                            0,
                                                                        sigmaY:
                                                                            0),
                                                                child: MemoryMediaGrid(
                                                                    mediaCollectionList:
                                                                        snapshot
                                                                            .data)),
                                                            GestureDetector(
                                                              onTap: () =>
                                                                  onTapCollection(
                                                                      index),
                                                              child: Container(
                                                                color: Colors
                                                                    .transparent,
                                                              ),
                                                            )
                                                          ],
                                                        )),
                                            ),
                                            Center(
                                              child: GestureDetector(
                                                onTap: () =>
                                                    onTapCollection(index),
                                                child: ShadowText(
                                                  photoCollectionTitle,
                                                  shadowColor: Theme.of(context)
                                                      .primaryColor,
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                            if (mediaCollectionList[index]
                                                    .module ==
                                                'CUSTOM')
                                              Positioned(
                                                  top: -8,
                                                  right: -12,
                                                  child: PopupMenuButton(
                                                    onSelected: (valueFn) {
                                                      valueFn();
                                                    },
                                                    iconSize: 15,
                                                    itemBuilder: (context) {
                                                      return [
                                                        PopupMenuItem(
                                                          child: Text('Delete'),
                                                          value: () async {
                                                            final collection =
                                                                mediaCollectionList[
                                                                    index];
                                                            collection
                                                                    .isActive =
                                                                false;
                                                            await handleFuture<
                                                                    MediaCollection>(
                                                                () => commonRemoteDataSource
                                                                    .saveMediaCollection(
                                                                        collection));
                                                            _memoryBloc.add(
                                                                GetMediaCollectionListEvent());
                                                          },
                                                        )
                                                      ];
                                                    },
                                                  ))
                                          ],
                                        );
                                      } else {
                                        return GridPlaceholder(
                                          mediaCount: 4,
                                        );
                                      }
                                    }))));
                  },
                ),
              );
            }
            return EmptyWidget();
          }),
    );
  }

  void onTapCollection(final int index) async {
    if (await commonRemoteDataSource.isConnected()) {
      await EasyLoading.show(
          status: "Loading...", maskType: EasyLoadingMaskType.black);
      List<MediaCollectionMapping> mediaCollectionMappingList =
          await commonRemoteDataSource.getMediaCollectionMappingByCollection(
              mediaCollectionList[index],
              mediaType: widget.arguments['mediaType']);
      await EasyLoading.dismiss();
      final result = await Navigator.of(appNavigatorContext(context))
          .push(MaterialPageRoute(
        builder: (context) => MediaWallLayout(
          selectMode: widget.arguments['selectMode'] ?? false,
          mediaType: widget.arguments['mediaType'],
          onMediaCollectionListChangeCallback: () {
            _memoryBloc.add(GetMediaCollectionListEvent());
          },
          title: mediaCollectionList[index].name,
          mediaCollectionMappingList: mediaCollectionMappingList,
        ),
      ));
      if ((widget.arguments['selectMode'] ?? false) &&
          result != null &&
          (result as List).isNotEmpty) {
        Navigator.of(context).pop(result);
      }
    }
  }

  Future showNewMediaCollectionDialog(BuildContext context) async {
    final TextEditingController _textFieldController = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text('Create new collection'),
                content: Container(
                  height: 60,
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
                    child: new Text('Submit'),
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
}
