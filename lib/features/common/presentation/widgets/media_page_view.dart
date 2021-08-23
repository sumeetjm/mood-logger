import 'dart:io';

import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mood_manager/core/constants/app_constants.dart';
import 'package:mood_manager/features/common/data/datasources/common_remote_data_source.dart';
import 'package:mood_manager/features/common/data/models/media_collection_mapping_parse.dart';
import 'package:mood_manager/features/common/data/models/media_collection_parse.dart';
import 'package:mood_manager/features/common/data/models/media_parse.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/common/domain/entities/base_states.dart';
import 'package:mood_manager/features/common/domain/entities/media.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection_mapping.dart';
import 'package:mood_manager/features/common/presentation/widgets/empty_widget.dart';
import 'package:mood_manager/features/common/presentation/widgets/loading_widget.dart';
import 'package:mood_manager/features/common/presentation/widgets/video_trim_view.dart';
import 'package:mood_manager/features/memory/data/datasources/memory_remote_data_source.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:sliding_panel/sliding_panel.dart';
import 'package:uuid/uuid.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:mood_manager/home.dart';

class MediaPageView extends StatefulWidget {
  final List<MediaCollectionMapping> mediaCollectionList;
  final List<Media> mediaList;
  final List<ParseFile> fileList;
  final Future<List<MediaCollectionMapping>> future;
  final int initialIndex;
  final MediaCollectionMapping initialItem;
  final ValueChanged<List<MediaCollectionMapping>>
      saveMediaCollectionMappingList;
  final ValueChanged<Media> goToMemoryCallback;
  final bool showAddToCollection;
  final ValueChanged<Media> setAsProfilePicCallback;
  final String tagSuffix;
  final ValueChanged<MediaCollectionMapping> addToCollectionCallback;
  MediaPageView({
    Key key,
    this.mediaCollectionList,
    this.mediaList,
    this.fileList,
    this.future,
    this.initialIndex,
    this.initialItem,
    this.saveMediaCollectionMappingList,
    this.addToCollectionCallback,
    this.goToMemoryCallback,
    this.setAsProfilePicCallback,
    this.tagSuffix = "",
    this.showAddToCollection = true,
  }) : super(key: key);

  @override
  _MediaPageViewState createState() => _MediaPageViewState();
}

class _MediaPageViewState extends State<MediaPageView> {
  PageController _controller;
  Map<String, MapEntry<Future, CachedVideoPlayerController>>
      videoPlayerControllerMap = {};
  bool slideShow = false;
  // ignore: non_constant_identifier_names
  Future<Directory> TEMP_DIR;
  Uuid uuid;
  MemoryRemoteDataSource memoryRemoteDataSource = sl<MemoryRemoteDataSource>();
  CommonRemoteDataSource commonRemoteDataSource = sl<CommonRemoteDataSource>();
  TransformationController transformationController =
      TransformationController();
  ScrollPhysics scrollPhysics = AlwaysScrollableScrollPhysics();
  var photoViewController = PhotoViewController();

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex ?? 0);
    TEMP_DIR = getTemporaryDirectory();
    uuid = sl<Uuid>();
    photoViewController.addIgnorableListener(() {
      setState(() {
        if (photoViewController.value.scale <= 1) {
          scrollPhysics = AlwaysScrollableScrollPhysics();
        } else {
          scrollPhysics = NeverScrollableScrollPhysics();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildingImageSlider();
  }

  Widget _buildingImageSlider() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Builder(
        builder: (context) {
          if (widget.future != null) {
            return _buildPagerViewSliderFromCallback();
          } else if (widget.mediaCollectionList != null) {
            return Stack(
              children: [
                _buildPagerViewSliderFromMediaCollection(widget
                    .mediaCollectionList
                    .where((element) => element.isActive)
                    .toList()),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.3),
                    child: IconButton(
                      color: slideShow
                          ? Theme.of(context).accentColor
                          : Colors.white,
                      icon: Icon(Icons.slideshow),
                      onPressed: () {
                        setState(() {
                          slideShow = !slideShow;
                        });
                        if (slideShow) {
                          Future.delayed(Duration(seconds: 2), animatePage);
                        }
                      },
                    ),
                  ),
                ),
                Positioned(
                    bottom: 0,
                    right: MediaQuery.of(context).size.width * 0.55,
                    child: CircleAvatar(
                        backgroundColor: Colors.black.withOpacity(0.3),
                        child: IconButton(
                          color: Colors.white,
                          icon: Icon(Icons.arrow_left),
                          onPressed: () {
                            _controller.previousPage(
                                duration: Duration(milliseconds: 500),
                                curve: Curves.easeIn);
                          },
                        ))),
                Positioned(
                    bottom: 0,
                    left: MediaQuery.of(context).size.width * 0.55,
                    child: CircleAvatar(
                        backgroundColor: Colors.black.withOpacity(0.3),
                        child: IconButton(
                          color: Colors.white,
                          icon: Icon(Icons.arrow_right),
                          onPressed: () {
                            _controller.nextPage(
                                duration: Duration(milliseconds: 500),
                                curve: Curves.easeIn);
                          },
                        ))),
                //if (photo.collection.module == 'MEMORY')
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.3),
                    child: PopupMenuButton(
                      child: IconButton(
                        color: Colors.white,
                        icon: Icon(Icons.more_vert),
                        onPressed: null,
                        disabledColor: Colors.white,
                      ),
                      elevation: 3.2,
                      onCanceled: () {
                        print('You have not chossed anything');
                      },
                      tooltip: 'This is tooltip',
                      onSelected: (fn) => fn(),
                      itemBuilder: (BuildContext context) {
                        final popupMap = {
                          if ((widget
                                          .mediaCollectionList[
                                              _controller.page.round()]
                                          .media
                                          .mediaType ==
                                      'PHOTO' &&
                                  AppConstants.allowImageCropping) ||
                              (widget
                                          .mediaCollectionList[
                                              _controller.page.round()]
                                          .media
                                          .mediaType ==
                                      'VIDEO' &&
                                  AppConstants.allowVideoTrimming))
                            'Edit': () {
                              if (widget
                                      .mediaCollectionList[
                                          _controller.page.round()]
                                      .media
                                      .mediaType ==
                                  'VIDEO') {
                                editVideo();
                              } else {
                                editPhoto();
                              }
                            },
                          'Delete': delete,
                          if (widget.setAsProfilePicCallback != null &&
                              widget
                                      .mediaCollectionList[
                                          _controller.page.round()]
                                      .media
                                      .mediaType ==
                                  'PHOTO')
                            'Set as profile picture': setAsProfilePicCallback,
                          if (widget.goToMemoryCallback != null)
                            'Go to Memory': goToMemory,
                          if (widget.showAddToCollection)
                            'Add to collection': () {
                              addToCollection(widget
                                  .mediaCollectionList[_controller.page.round()]
                                  .media);
                            },
                        };
                        return popupMap.keys.map((key) {
                          return PopupMenuItem(
                            value: popupMap[key],
                            child: Text(key),
                          );
                        }).toList();
                      },
                    ),
                  ),
                )
              ],
            );
          } else {
            return LoadingWidget();
          }
        },
      ),
    );
  }

  Widget _buildPagerViewSliderFromCallback() {
    return FutureBuilder<List<MediaCollectionMapping>>(
        future: widget.future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _controller = PageController(
                initialPage: snapshot.data
                    .indexWhere((element) => element == widget.initialItem));
            return _buildPagerViewSliderFromMediaCollection(snapshot.data);
          } else {
            return EmptyWidget();
          }
        });
  }

  Widget _buildPagerViewSliderFromMediaCollection(
      List<MediaCollectionMapping> mediaCollectionMappingList) {
    final List<MediaCollectionMapping> videoList = mediaCollectionMappingList
        .where((e) => e.media.mediaType == "VIDEO")
        .toList();
    videoPlayerControllerMap = getVideoControllerMapByMedia(videoList);
    //PhotoView.customChild(child: child);
    /*PhotoViewGallery.builder(
      itemCount: mediaCollectionMappingList.length,
      builder: (context, index) {
        final mediaCollectionMapping = mediaCollectionMappingList[index];

        return PhotoViewGalleryPageOptions(
            imageProvider: mediaCollectionMapping.media.imageProvider);
      },
    );*/
    /* return Center(
      child: AspectRatio(
        aspectRatio: videoPlayerControllerMap[mediaCollectionMappingList[0]
                .media
                .tag(suffix: widget.tagSuffix)]
            .value
            .value
            .aspectRatio,
        child: CachedVideoPlayer(videoPlayerControllerMap[
                mediaCollectionMappingList[0]
                    .media
                    .tag(suffix: widget.tagSuffix)]
            .value),
      ),
    );*/

    return PageView.builder(
        physics: scrollPhysics,
        controller: _controller,
        itemCount: mediaCollectionMappingList.length,
        itemBuilder: (BuildContext context, int index) {
          final mediaCollectionMapping = mediaCollectionMappingList[index];
          if (mediaCollectionMapping.media.mediaType == "VIDEO") {
            return videoFromMedia(mediaCollectionMapping, index);
          }

          return PhotoView.customChild(
              controller: photoViewController,
              /* scaleStateChangedCallback: (value) {
                if (value == PhotoViewScaleState.zoomedOut) {
                  setState(() {
                    photoViewController.scale = 0.0;
                  });
                }
              },*/
              minScale: 1.0,
              child: imageFromMedia(mediaCollectionMapping, index));
        });
  }

  Widget imageFromMedia(MediaCollectionMapping photo, int index) {
    return Hero(
      tag: photo.media.tag(suffix: widget.tagSuffix),
      child: ClipRRect(
        child: photo.media.image,
      ),
    );
  }

  Widget videoFromMedia(MediaCollectionMapping video, int index) {
    return FutureBuilder(
      future:
          videoPlayerControllerMap[video.media.tag(suffix: widget.tagSuffix)]
              .key,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Hero(
              tag: video.media.tag(suffix: widget.tagSuffix),
              child: VisibilityDetector(
                  key: ValueKey(video.media.id),
                  onVisibilityChanged: (info) {
                    if (info.visibleFraction == 0.0) {
                      if (videoPlayerControllerMap[
                                  video.media.tag(suffix: widget.tagSuffix)]
                              ?.value
                              ?.value
                              ?.isPlaying ??
                          false) {
                        videoPlayerControllerMap[
                                video.media.tag(suffix: widget.tagSuffix)]
                            .value
                            .pause();
                      }
                    } else {
                      if (!(videoPlayerControllerMap[
                                  video.media.tag(suffix: widget.tagSuffix)]
                              ?.value
                              ?.value
                              ?.isPlaying ??
                          false)) {
                        videoPlayerControllerMap[
                                video.media.tag(suffix: widget.tagSuffix)]
                            .value
                            .play();
                        videoPlayerControllerMap[
                                video.media.tag(suffix: widget.tagSuffix)]
                            .value
                            .setLooping(true);
                      }
                    }
                  },
                  child: GestureDetector(
                      onTap: () {
                        if (videoPlayerControllerMap[
                                    video.media.tag(suffix: widget.tagSuffix)]
                                ?.value
                                ?.value
                                ?.isPlaying ??
                            false) {
                          videoPlayerControllerMap[
                                  video.media.tag(suffix: widget.tagSuffix)]
                              .value
                              .pause();
                        } else {
                          videoPlayerControllerMap[
                                  video.media.tag(suffix: widget.tagSuffix)]
                              .value
                              .play();
                        }
                      },
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: videoPlayerControllerMap[
                                  video.media.tag(suffix: widget.tagSuffix)]
                              .value
                              .value
                              .aspectRatio,
                          child: CachedVideoPlayer(videoPlayerControllerMap[
                                  video.media.tag(suffix: widget.tagSuffix)]
                              .value),
                        ),
                      ))));
        }
        return LoadingWidget();
      },
    );
  }

  Map<String, MapEntry<Future, CachedVideoPlayerController>>
      getVideoControllerMapByMedia(
          final List<MediaCollectionMapping> mediaCollectionMappingList) {
    return Map.fromEntries(mediaCollectionMappingList.map((e) {
      final cachedVideoPlayerController = e.media.videoController;
      final playerInitFuture = cachedVideoPlayerController.initialize();
      return MapEntry(e.media.tag(suffix: widget.tagSuffix),
          MapEntry(playerInitFuture, cachedVideoPlayerController));
    }));
  }

  animatePage() {
    if (slideShow) {
      int nextPage = _controller.page.round() + 1;
      if (nextPage == widget.mediaCollectionList.length) {
        nextPage = 0;
      }
      _controller
          .animateToPage(nextPage,
              duration: Duration(seconds: 1), curve: Curves.linear)
          .then((_) => Future.delayed(Duration(seconds: 10), animatePage));
    } else {
      return;
    }
  }

  void editPhoto() async {
    final index = _controller.page.round();
    final selectedMediaCollection = widget.mediaCollectionList[index];
    var toEditFile = await selectedMediaCollection.media.mediaFile();
    final editedFile =
        await cropImage(toEditFile, selectedMediaCollection.collection.module);
    if (editedFile != null) {
      await selectedMediaCollection.media.delete();
      selectedMediaCollection.media.file = ParseFile(editedFile);
      await selectedMediaCollection.media
          .setThumbnail((await TEMP_DIR).path, uuid.v1());
      await selectedMediaCollection.media.setDominantColor();
      setState(() {});
      widget.saveMediaCollectionMappingList?.call(widget.mediaCollectionList);
      if (widget.mediaCollectionList
          .where((element) => element.isActive)
          .isEmpty) {
        Navigator.of(context).pop();
      }
    }
  }

  void editVideo() async {
    final index = _controller.page.round();
    final toEditFile =
        (await widget.mediaCollectionList[index].media.file.download()).file;
    File editedFile = await Navigator.of(appNavigatorContext(context))
        .push(MaterialPageRoute(builder: (context) {
      return VideoTrimView(
        file: toEditFile,
      );
    }));
    if (editedFile != null) {
      var selectedMediaCollection =
          widget.mediaCollectionList[_controller.page.round()];
      editedFile = BaseUtil.renameFileSync(editedFile, uuid.v1());
      await selectedMediaCollection.media.delete();
      selectedMediaCollection.media.file = ParseFile(editedFile);
      await selectedMediaCollection.media
          .setThumbnail((await TEMP_DIR).path, uuid.v1());
      await selectedMediaCollection.media.setDominantColor();
      setState(() {
        final List<MediaCollectionMapping> videoList = widget
            .mediaCollectionList
            .where((e) => e.media.mediaType == "VIDEO" && e.isActive)
            .toList();
        videoPlayerControllerMap = getVideoControllerMapByMedia(videoList);
        widget.saveMediaCollectionMappingList?.call(widget.mediaCollectionList);
        if (BaseUtil.isEmpty(widget.mediaCollectionList)) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  Future<File> cropImage(File image, String module) async {
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: image.path,
      maxWidth: 1080,
      maxHeight: 1080,
      aspectRatio: module == 'PROFILE_PICTURE'
          ? CropAspectRatio(ratioX: 1.0, ratioY: 1.0)
          : null,
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Preview',
        toolbarColor: Colors.blue,
        toolbarWidgetColor: Colors.white,
      ),
    );
    return croppedImage;
  }

  void delete() {
    final index = _controller.page.round();
    widget.mediaCollectionList[index].isActive = false;
    if (widget.mediaCollectionList[index].id == null) {
      widget.mediaCollectionList.removeAt(index);
    }
    videoPlayerControllerMap.remove(widget
        .mediaCollectionList[_controller.page.round()].media
        .tag(suffix: widget.tagSuffix));
    setState(() {});
    widget.saveMediaCollectionMappingList?.call(widget.mediaCollectionList);
    if (BaseUtil.isEmpty(widget.mediaCollectionList)) {
      Navigator.of(context).pop();
    }
  }

  goToMemory() {
    final index = _controller.page.round();
    final selectedMediaCollection = widget.mediaCollectionList[index];
    widget.goToMemoryCallback?.call(selectedMediaCollection.media);
  }

  setAsProfilePicCallback() async {
    final selectedMediaCollection =
        widget.mediaCollectionList[_controller.page.round()];
    if (selectedMediaCollection.collection.module == 'PROFILE_PICTURE') {
      widget.setAsProfilePicCallback?.call(selectedMediaCollection.media);
    } else {
      final File toBeProfilePictureFile = await cropImage(
          await selectedMediaCollection.media.mediaFile(), "PROFILE_PICTURE");
      if (toBeProfilePictureFile != null) {
        final profilePicture = MediaParse(
          mediaType: "PHOTO",
          file: ParseFile(toBeProfilePictureFile),
        );
        profilePicture.setThumbnail((await TEMP_DIR).path, uuid.v1());
        profilePicture.setDominantColor();
        widget.setAsProfilePicCallback?.call(profilePicture);
      }
    }
  }

  Future<void> addToCollection(Media media) async {
    MediaCollection collectionInWhichAdded;
    memoryRemoteDataSource
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
        var collectionInWhichAddedAndSaved;
        if (collectionInWhichAdded.id == null) {
          collectionInWhichAddedAndSaved = await commonRemoteDataSource
              .saveMediaCollection(collectionInWhichAdded);
        } else {
          collectionInWhichAddedAndSaved = await commonRemoteDataSource
              .saveMediaCollection(collectionInWhichAdded);
        }
        final MediaCollectionMapping saved =
            await handleFuture<MediaCollectionMapping>(
                () => commonRemoteDataSource.saveMediaCollectionMapping(
                    MediaCollectionMappingParse(
                      collection: collectionInWhichAddedAndSaved,
                      media: media,
                    ),
                    skipIfAlreadyPresent: true));
        if (collectionInWhichAdded.id == null) {
          Fluttertoast.showToast(
              gravity: ToastGravity.TOP,
              msg: 'Already added to ${collectionInWhichAdded.name}',
              backgroundColor: Colors.green);
        } else {
          Fluttertoast.showToast(
              gravity: ToastGravity.TOP,
              msg: 'Added to ${collectionInWhichAdded.name}',
              backgroundColor: Colors.green);
        }
        setState(() {
          widget.addToCollectionCallback?.call(saved);
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
              module: 'CUSTOM',
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
              widget.mediaCollectionList[_controller.page.round()].collection !=
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
}
