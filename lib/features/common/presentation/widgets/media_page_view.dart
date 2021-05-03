import 'dart:io';

import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:mood_manager/features/common/domain/entities/media.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection_mapping.dart';
import 'package:mood_manager/features/common/presentation/widgets/empty_widget.dart';
import 'package:mood_manager/features/common/presentation/widgets/loading_widget.dart';
import 'package:mood_manager/features/common/presentation/widgets/video_trim_view.dart';
import 'package:mood_manager/features/memory/presentation/pages/memory_list_page.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:image/image.dart' as img;

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
  MediaPageView({
    Key key,
    this.mediaCollectionList,
    this.mediaList,
    this.fileList,
    this.future,
    this.initialIndex,
    this.initialItem,
    this.saveMediaCollectionMappingList,
    this.goToMemoryCallback,
  }) : super(key: key);

  @override
  _MediaPageViewState createState() => _MediaPageViewState();
}

class _MediaPageViewState extends State<MediaPageView> {
  PageController _controller;
  Map<String, MapEntry<Future, CachedVideoPlayerController>>
      videoPlayerControllerMap = {};
  bool slideShow = false;
  Future<Directory> tempDirectoryFuture;
  final Uuid uuid = sl<Uuid>();
  Trimmer _trimmer = sl<Trimmer>();

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex ?? 0);
    tempDirectoryFuture = getTemporaryDirectory();
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
                  child: Container(
                      color: Colors.transparent,
                      child: CircleAvatar(
                        backgroundColor:
                            slideShow ? Colors.white : Colors.transparent,
                        child: IconButton(
                          color: slideShow ? Colors.black : Colors.white,
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
                      )),
                ),
                Positioned(
                    bottom: 0,
                    right: MediaQuery.of(context).size.width * 0.55,
                    child: Container(
                        color: Colors.transparent,
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
                    child: Container(
                        color: Colors.transparent,
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
                  child: Container(
                    color: Colors.transparent,
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
                          if (widget.goToMemoryCallback != null)
                            'Go to Memory': goToMemory,
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
    return PageView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        controller: _controller,
        itemCount: mediaCollectionMappingList.length,
        itemBuilder: (BuildContext context, int index) {
          final mediaCollectionMapping = mediaCollectionMappingList[index];
          if (mediaCollectionMapping.media.mediaType == "VIDEO") {
            return videoFromMedia(mediaCollectionMapping, index);
          }

          return InteractiveViewer(
            //  transformationController: TransformationController(),
            child: imageFromMedia(mediaCollectionMapping, index),
            maxScale: 5.0,
            onInteractionStart: (details) {
              setState(() {
                slideShow = false;
              });
            },
          );
        });
    ;
  }

  Widget imageFromMedia(MediaCollectionMapping photo, int index) {
    return Hero(
      tag: photo.media.tag,
      child: ClipRRect(
        child: photo.media.image,
      ),
    );
  }

  Widget videoFromMedia(MediaCollectionMapping video, int index) {
    return FutureBuilder(
      future: videoPlayerControllerMap[video.media.tag].key,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Hero(
              tag: video.media.tag,
              child: VisibilityDetector(
                key: ValueKey(video.media.id),
                onVisibilityChanged: (info) {
                  if (info.visibleFraction == 0.0) {
                    if (videoPlayerControllerMap[video.media.tag]
                            ?.value
                            ?.value
                            ?.isPlaying ??
                        false) {
                      videoPlayerControllerMap[video.media.tag].value.pause();
                    }
                  }
                },
                child: GestureDetector(
                  onTap: () {
                    if (videoPlayerControllerMap[video.media.tag]
                            ?.value
                            ?.value
                            ?.isPlaying ??
                        false) {
                      videoPlayerControllerMap[video.media.tag].value.pause();
                    } else {
                      videoPlayerControllerMap[video.media.tag].value.play();
                    }
                  },
                  child: CachedVideoPlayer(
                      videoPlayerControllerMap[video.media.tag].value),
                ),
              ));
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
      final initializeFuture = cachedVideoPlayerController.initialize();
      return MapEntry(
          e.media.tag, MapEntry(initializeFuture, cachedVideoPlayerController));
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
    final selectedMediaCollection =
        widget.mediaCollectionList[_controller.page.round()];
    var parseFile = await selectedMediaCollection.media.file.download();
    final newFile = await cropImage((parseFile).file);
    if (newFile != null) {
      final newThumbnailFile =
          File((await tempDirectoryFuture).path + "/" + uuid.v1() + ".jpg");
      newThumbnailFile.writeAsBytesSync(img.encodeJpg(img
          .copyResize(img.decodeImage(newFile.readAsBytesSync()), width: 200)));
      selectedMediaCollection.media.file.delete();
      selectedMediaCollection.media.file?.file?.delete();
      selectedMediaCollection.media.file = ParseFile(newFile);
      selectedMediaCollection.media.thumbnail.delete();
      selectedMediaCollection.media.thumbnail?.file?.delete();
      selectedMediaCollection.media.thumbnail = ParseFile(newThumbnailFile);
      setState(() {});
      widget.saveMediaCollectionMappingList?.call(widget.mediaCollectionList);
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

  void delete() {
    widget.mediaCollectionList[_controller.page.round()].isActive = false;
    videoPlayerControllerMap
        .remove(widget.mediaCollectionList[_controller.page.round()].media.tag);
    setState(() {});
    widget.saveMediaCollectionMappingList?.call(widget.mediaCollectionList);
    if (widget.mediaCollectionList.isEmpty) {
      Navigator.of(context).pop();
    }
  }

  void editVideo() async {
    await _trimmer.loadVideo(
      videoFile: (await widget
              .mediaCollectionList[_controller.page.round()].media.file
              .download())
          .file,
    );
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return VideoTrimView(
          trimmer: _trimmer,
          saveCallback: (value) async {
            var selectedMediaCollection =
                widget.mediaCollectionList[_controller.page.round()];
            final newThumbnailFile = File(
                (await tempDirectoryFuture).path + "/" + uuid.v1() + ".jpg");
            value = value.renameSync(value.parent.path +
                "/" +
                uuid.v1() +
                value.path.substring(value.path.lastIndexOf(".")));
            await VideoThumbnail.thumbnailFile(
              video: value.path,
              thumbnailPath: newThumbnailFile.path,
              imageFormat: ImageFormat.JPEG,
              maxHeight:
                  200, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
              quality: 50,
            );
            selectedMediaCollection.media.file.delete();
            selectedMediaCollection.media.file?.file?.delete();
            selectedMediaCollection.media.file = ParseFile(value);
            selectedMediaCollection.media.thumbnail.delete();
            selectedMediaCollection.media.thumbnail?.file?.delete();
            selectedMediaCollection.media.thumbnail =
                ParseFile(newThumbnailFile);
            setState(() {
              widget.saveMediaCollectionMappingList
                  ?.call(widget.mediaCollectionList);
              final List<MediaCollectionMapping> videoList = widget
                  .mediaCollectionList
                  .where((e) => e.media.mediaType == "VIDEO" && e.isActive)
                  .toList();
              videoPlayerControllerMap =
                  getVideoControllerMapByMedia(videoList);
            });
          });
    }));
  }

  goToMemory() {
    final selectedMediaCollection =
        widget.mediaCollectionList[_controller.page.round()];
    if (widget.goToMemoryCallback == null) {
      Navigator.of(context).pop();
    } else {
      widget.goToMemoryCallback?.call(selectedMediaCollection.media);
    }
  }
}
