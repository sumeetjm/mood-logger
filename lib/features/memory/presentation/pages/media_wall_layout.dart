import 'dart:io';
import 'dart:math';

import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_wall_layout/flutter_wall_layout.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mood_manager/core/constants/app_constants.dart';
import 'package:mood_manager/features/common/data/datasources/common_remote_data_source.dart';
import 'package:mood_manager/features/common/data/models/media_collection_parse.dart';
import 'package:mood_manager/features/common/domain/entities/base_states.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection_mapping.dart';
import 'package:mood_manager/features/common/presentation/widgets/media_page_view.dart';
import 'package:mood_manager/features/common/presentation/widgets/video_trim_view.dart';
import 'package:mood_manager/features/memory/data/datasources/memory_remote_data_source.dart';
import 'package:mood_manager/features/profile/data/datasources/user_profile_remote_data_source.dart';
import 'package:mood_manager/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:tinycolor/tinycolor.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/common/data/models/media_collection_mapping_parse.dart';
import 'package:sliding_panel/sliding_panel.dart';
import '../../../../home.dart';
import '../../../../injection_container.dart';
import 'media_grid_view.dart';
import 'memory_list_page.dart';

// ignore: must_be_immutable
class MediaWallLayout extends StatefulWidget {
  MediaWallLayout({
    Key key,
    this.title = 'Wall Layout Demo',
    this.mediaCollectionMappingList,
    this.onMediaCollectionListChangeCallback,
    this.selectMode,
    this.mediaType,
  }) : super(key: key);
  List<MediaCollectionMapping> mediaCollectionMappingList;
  Future<List<MediaCollectionMapping>> mediaCollectionMappingListFuture;
  Function onMediaCollectionListChangeCallback;
  final String mediaType;
  final String title;
  final bool selectMode;
  @override
  _MediaWallLayoutState createState() => _MediaWallLayoutState();
}

class _MediaWallLayoutState extends State<MediaWallLayout>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Axis _direction;
  final random = Random();
  bool isPhotoOnly = false;
  bool isVideoOnly = false;
  String mediaType;
  final commonRemoteDataSource = sl<CommonRemoteDataSource>();
  final userProfileRemoteDataSource = sl<UserProfileRemoteDataSource>();
  final memoryRemoteDataSource = sl<MemoryRemoteDataSource>();
  ProfileBloc _profileBloc;
  final controller = DragSelectGridViewController();
  final Uuid uuid = sl<Uuid>();
  // ignore: non_constant_identifier_names
  Future<Directory> TEMP_DIR;
  String view;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    _direction = Axis.vertical;
    _controller.forward(from: 0);
    _profileBloc = BlocProvider.of<ProfileBloc>(context);
    controller.addListener(scheduleRebuild);
    TEMP_DIR = getTemporaryDirectory();
    view = widget.selectMode ? 'Grid view' : 'Wall view';
  }

  @override
  void dispose() {
    controller.removeListener(scheduleRebuild);
    super.dispose();
  }

  void scheduleRebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.selectMode
            ? Text('(${controller.value.selectedIndexes.length}) Selected')
            : DropdownButtonFormField<String>(
                dropdownColor:
                    TinyColor(Theme.of(context).primaryColor).lighten(5).color,
                icon: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 12.0, 0),
                  child: Icon(Icons.keyboard_arrow_down),
                ),
                items: ['Wall view', 'Grid view'].map((view) {
                  return new DropdownMenuItem<String>(
                    value: view,
                    child: Text(
                      view,
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    controller.clear();
                    view = value;
                  });
                },
                value: view,
                decoration: InputDecoration(
                  errorStyle: TextStyle(fontSize: 12),
                  enabledBorder: InputBorder.none,
                  fillColor: Colors.white,
                  labelText: 'View',
                  labelStyle: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
        actions: [
          if (widget.selectMode)
            IconButton(
                icon: Icon(Icons.done_rounded),
                onPressed: () {
                  var selectedMappingList = widget.mediaCollectionMappingList
                      .asMap()
                      .entries
                      .where((element) => controller.value.selectedIndexes
                          .contains(element.key))
                      .map((e) => e.value)
                      .toList();
                  Navigator.of(context).pop(selectedMappingList);
                }),
          if (widget.selectMode)
            IconButton(
                icon: Icon(Icons.close_rounded),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          if (!widget.selectMode && view == 'Grid view')
            PopupMenuButton(
              elevation: 3.2,
              onCanceled: () {
                print('You have not chossed anything');
              },
              tooltip: 'This is tooltip',
              onSelected: (fn) => fn(),
              itemBuilder: (BuildContext context) {
                final popupMap = {
                  if (controller.value.selectedIndexes.length == 1 &&
                      isEditAllowed())
                    'Edit': edit,
                  if (controller.value.selectedIndexes.length > 0)
                    'Delete': delete,
                  if (controller.value.selectedIndexes.length > 0)
                    'Deselect All': deselectAll,
                  if (controller.value.selectedIndexes.length !=
                      widget.mediaCollectionMappingList.length)
                    'Select All': selectAll,
                  if (controller.value.selectedIndexes.length > 0)
                    'Add to other collection': addToCollection,
                };
                return popupMap.keys.map((key) {
                  return PopupMenuItem(
                    value: popupMap[key],
                    child: Text(key),
                  );
                }).toList();
              },
            ),
        ],
      ),
      body: pageLayout()[view],
    );
  }

  isEditAllowed() {
    return ((widget
                    .mediaCollectionMappingList[
                        controller.value.selectedIndexes.first]
                    .media
                    .mediaType ==
                'PHOTO' &&
            AppConstants.allowImageCropping) ||
        (widget
                    .mediaCollectionMappingList[
                        controller.value.selectedIndexes.first]
                    .media
                    .mediaType ==
                'VIDEO' &&
            AppConstants.allowVideoTrimming));
  }

  pageLayout() {
    return {
      'Wall view': Builder(
        builder: (context) => buildWallLayout(),
      ),
      'Grid view': Builder(
        builder: (context) => buildSelectableGrid(),
      )
    };
  }

  buildSelectableGrid() {
    return AnimationLimiter(
      child: DragSelectGridView(
        gridController: controller,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: widget.mediaCollectionMappingList.length,
        itemBuilder: (BuildContext context, int index, bool selected) {
          if (selected || controller.value.selectedIndexes.isNotEmpty) {
            return AnimationConfiguration.staggeredGrid(
                columnCount: 2,
                position: index,
                duration: const Duration(milliseconds: 500),
                child: ScaleAnimation(
                    child: FadeInAnimation(
                        child: SelectableImageItem(
                  selectColor: Theme.of(context).accentColor,
                  mediaCollection: widget.mediaCollectionMappingList[index],
                  selected: selected,
                ))));
          }
          return AnimationConfiguration.staggeredGrid(
              columnCount: 2,
              position: index,
              duration: const Duration(milliseconds: 500),
              child: ScaleAnimation(
                  child: FadeInAnimation(
                      child: GestureDetector(
                onTap: widget.selectMode
                    ? () {}
                    : () {
                        Navigator.of(appNavigatorContext(context))
                            .push(MaterialPageRoute(builder: (context) {
                          return MediaPageView(
                              addToCollectionCallback:
                                  (mediaCollectionMapping) {
                                widget.onMediaCollectionListChangeCallback
                                    ?.call();
                              },
                              goToMemoryCallback: (media) async {
                                final memoryIdList =
                                    await handleFuture<List<String>>(() =>
                                        memoryRemoteDataSource
                                            .getMemoryIdListByMedia(media));
                                if (memoryIdList.isNotEmpty) {
                                  Navigator.of(appNavigatorContext(context))
                                      .push(MaterialPageRoute(
                                    builder: (context) {
                                      return MemoryListPage(
                                        showMenuButton: false,
                                        arguments: {
                                          'media': media,
                                          'addToCollectionCallback':
                                              (mediaCollectionMapping) {
                                            widget
                                                .onMediaCollectionListChangeCallback
                                                ?.call();
                                          }
                                        },
                                      );
                                    },
                                  ));
                                } else {
                                  Fluttertoast.showToast(
                                      gravity: ToastGravity.TOP,
                                      msg: 'Entry not present',
                                      backgroundColor: Colors.red);
                                }
                              },
                              setAsProfilePicCallback: (value) {
                                _profileBloc.add(SaveProfilePictureEvent(
                                    null, null,
                                    media: value));
                              },
                              initialIndex: index,
                              mediaCollectionList:
                                  widget.mediaCollectionMappingList,
                              saveMediaCollectionMappingList:
                                  saveMediaCollectionList);
                        }));
                      },
                onDoubleTap: widget.selectMode
                    ? () {}
                    : () async {
                        edit(index);
                      },
                child: SelectableImageItem(
                  selectColor: Theme.of(context).accentColor,
                  mediaCollection: widget.mediaCollectionMappingList[index],
                  selected: selected,
                ),
              ))));
        },
      ),
    );
  }

  Future<dynamic> trimVideo(int index) async {
    var toEditFile =
        (await widget.mediaCollectionMappingList[index].media.mediaFile());
    File editedFile = await Navigator.of(appNavigatorContext(context))
        .push(MaterialPageRoute(builder: (context) {
      return VideoTrimView(
        file: toEditFile,
      );
    }));
    if (editedFile != null) {
      final selectedMediaCollection = widget.mediaCollectionMappingList[index];
      await selectedMediaCollection.media.delete();
      selectedMediaCollection.media.file = ParseFile(editedFile);
      selectedMediaCollection.media
          .setThumbnail((await TEMP_DIR).path, uuid.v1());
      selectedMediaCollection.media.setDominantColor();
      setState(() {
        saveMediaCollectionList(widget.mediaCollectionMappingList);
        widget.onMediaCollectionListChangeCallback?.call();
      });
    }
  }

  Future<File> cropImage(File image) async {
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: image.path,
      maxWidth: 1080,
      maxHeight: 1080,
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Preview',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white),
    );
    return croppedImage;
  }

  Widget buildWallLayout() {
    var buildStonesList = _buildStonesList();
    return WallLayout(
      stonePadding: 4,
      scrollDirection: _direction,
      stones: buildStonesList.isEmpty
          ? [
              Stone(
                id: 0,
                height: getMap(0)['height'],
                width: getMap(0)['width'],
                child: Container(
                  child: Center(
                    child: Text('No photos'),
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey, width: 1),
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 2,
                            color: Colors.grey,
                            spreadRadius: 1,
                            offset: Offset(1, 1))
                      ]),
                ),
              )
            ]
          : buildStonesList,
      layersCount: 3,
    );
  }

  Map getMap(index) {
    if (index < AppConstants.wallLayoutStoneMap.length) {
      return AppConstants.wallLayoutStoneMap[index];
    } else {
      return getMap(index - AppConstants.wallLayoutStoneMap.length);
    }
  }

  List<Stone> _buildStonesList() {
    return List.generate(widget.mediaCollectionMappingList.length, (index) {
      final stoneSizeMap = getMap(index);

      return Stone(
        id: index,
        height: stoneSizeMap['height'],
        width: stoneSizeMap['width'],
        child: ScaleTransition(
          scale: CurveTween(
                  curve: Interval(
                      0.0,
                      min(
                          1.0,
                          0.25 +
                              (stoneSizeMap['width'] * stoneSizeMap['height'])
                                      .toDouble() /
                                  6.0)))
              .animate(_controller),
          child: GestureDetector(
            onTap: () {
              Navigator.of(appNavigatorContext(context))
                  .push(MaterialPageRoute(builder: (context) {
                return MediaPageView(
                  addToCollectionCallback: (value) {
                    widget.onMediaCollectionListChangeCallback?.call();
                  },
                  mediaCollectionList: widget.mediaCollectionMappingList,
                  initialIndex: index,
                  goToMemoryCallback: (media) async {
                    final memoryIdList = await handleFuture<List<String>>(() =>
                        memoryRemoteDataSource.getMemoryIdListByMedia(media));
                    if (memoryIdList.isNotEmpty) {
                      Navigator.of(appNavigatorContext(context))
                          .push(MaterialPageRoute(
                        builder: (context) {
                          return MemoryListPage(
                              showMenuButton: false,
                              arguments: {
                                'media': media,
                                'addToCollectionCallback':
                                    (mediaCollectionMapping) {
                                  widget.onMediaCollectionListChangeCallback
                                      ?.call();
                                }
                              });
                        },
                      ));
                    } else {
                      Fluttertoast.showToast(
                          gravity: ToastGravity.TOP,
                          msg: 'Entry not present',
                          backgroundColor: Colors.red);
                    }
                  },
                  saveMediaCollectionMappingList: saveMediaCollectionList,
                  setAsProfilePicCallback: (value) {
                    _profileBloc
                        .add(SaveProfilePictureEvent(null, null, media: value));
                  },
                );
              }));
            },
            child: Hero(
              tag: widget.mediaCollectionMappingList[index].media
                  .tag(suffix: 'MEDIACOLLECTIONGRID'),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      image: widget.mediaCollectionMappingList[index].media
                          .thumbnailProvider,
                    ),
                    border: Border.all(color: Colors.grey, width: 1),
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 2,
                          color: widget.mediaCollectionMappingList[index].media
                                  .dominantColor ??
                              Colors.grey,
                          spreadRadius: 1,
                          offset: Offset(1, 1))
                    ]),
              ),
            ),
          ),
        ),
      );
    });
  }

  void delete() {
    widget.mediaCollectionMappingList.asMap().forEach((key, value) {
      value.isActive = !controller.value.selectedIndexes.contains(key);
      if (value.isActive) {
        value.media.delete();
      }
    });
    controller.clear();
    if (widget.mediaCollectionMappingList.isEmpty) {
      Navigator.of(appNavigatorContext(context))
          .pop(widget.mediaCollectionMappingList);
    }
    saveMediaCollectionList(widget.mediaCollectionMappingList);
    widget.onMediaCollectionListChangeCallback?.call();
  }

  void selectAll() {
    controller.value =
        Selection(widget.mediaCollectionMappingList.asMap().keys.toSet());
  }

  void deselectAll() {
    controller.clear();
  }

  Future<void> editPhoto(int index) async {
    final selectedMediaCollection = widget.mediaCollectionMappingList[index];
    var toEditFile = await selectedMediaCollection.media.mediaFile();
    final editedFile = await cropImage(toEditFile);
    if (editedFile != null) {
      await selectedMediaCollection.media.delete();
      selectedMediaCollection.media.file = ParseFile(editedFile);
      await selectedMediaCollection.media
          .setThumbnail((await TEMP_DIR).path, uuid.v1());
      await selectedMediaCollection.media.setDominantColor();
      setState(() {
        //widget.onChanged.call(widget.imageMediaCollectionList);
        saveMediaCollectionList(widget.mediaCollectionMappingList);
        widget.onMediaCollectionListChangeCallback?.call();
      });
    }
  }

  void edit(int index) async {
    if (widget.mediaCollectionMappingList[index].media.mediaType == 'VIDEO') {
      await trimVideo(index);
    } else {
      await editPhoto(index);
    }
  }

  Future<void> addToCollection() async {
    MediaCollection collectionInWhichAdded;
    sl<MemoryRemoteDataSource>()
        .getMediaCollectionListByModuleList(['CUSTOM']).then((value) async {
      collectionInWhichAdded = await showModalSlidingPanel(
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
      if (collectionInWhichAdded != null) {
        final mediaCollectionMappingListToBeSaved =
            controller.value.selectedIndexes
                .map((e) => MediaCollectionMappingParse(
                      collection: collectionInWhichAdded,
                      media: widget.mediaCollectionMappingList[e].media,
                    ))
                .toList();
        await handleFuture<List<MediaCollectionMapping>>(() =>
            sl<CommonRemoteDataSource>().saveMediaCollectionMappingList(
                mediaCollectionMappingListToBeSaved,
                skipIfAlreadyPresent: true));
        Fluttertoast.showToast(
            gravity: ToastGravity.TOP,
            msg: 'Added to ${collectionInWhichAdded.name}',
            backgroundColor: Colors.green);
        setState(() {
          widget.onMediaCollectionListChangeCallback?.call();
        });
      }
    });
  }

  List<Widget> panelContentCollectionOptions(
      BuildContext context, List<MediaCollection> value) {
    return [
      ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(
            MdiIcons.imageAlbum,
            color: Colors.white,
          ),
        ),
        title: Text('Create new collection'),
        onTap: () async {
          final collectionName = await showNewMediaCollectionDialog(context);
          final newMediaCollection = MediaCollectionParse(
              code: uuid.v1(),
              name: collectionName,
              mediaType: 'PHOTO',
              user: await ParseUser.currentUser());
          Navigator.of(context).pop(newMediaCollection);
        },
      ),
      Divider(
        thickness: 1,
        height: 1,
      ),
      ...value
          .where((element) =>
              widget
                  .mediaCollectionMappingList[
                      controller.value.selectedIndexes.first]
                  .collection !=
              element)
          .map((e) => [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: e.averageMediaColor ?? Colors.grey,
                    child: Icon(
                      MdiIcons.imageAlbum,
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

  saveMediaCollectionList(
      List<MediaCollectionMapping> mediaCollectionMappingList) async {
    widget.mediaCollectionMappingList = mediaCollectionMappingList
        .where((element) => element.isActive)
        .toList();
    EasyLoading.show(status: "Loading...", maskType: EasyLoadingMaskType.black);
    if (await commonRemoteDataSource.isConnected()) {
      await commonRemoteDataSource
          .saveMediaCollectionMappingList(mediaCollectionMappingList);
      EasyLoading.dismiss();
      widget.onMediaCollectionListChangeCallback?.call();
    } else {
      Fluttertoast.showToast(
          gravity: ToastGravity.TOP,
          msg: 'Unable to connect',
          backgroundColor: Colors.red);
    }
    final userProfile =
        await userProfileRemoteDataSource.getCurrentUserProfile();
    if (mediaCollectionMappingList.any((element) => !element.isActive) &&
        mediaCollectionMappingList
                .firstWhere((element) => !element.isActive)
                .media ==
            userProfile.profilePicture) {
      userProfile.profilePicture = AppConstants.DEFAULT_PROFILE_MEDIA;
      _profileBloc.add(SaveProfilePictureEvent(null, userProfile));
    }
  }
}
