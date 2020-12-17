import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';
import 'package:mood_manager/features/common/domain/entities/media.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/common/presentation/widgets/empty_widget.dart';
import 'package:mood_manager/features/common/presentation/widgets/loading_widget.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:visibility_detector/visibility_detector.dart';

class MediaPageView extends StatefulWidget {
  final List<MediaCollection> mediaCollectionList;
  final List<Media> mediaList;
  final List<ParseFile> fileList;
  final Function callback;
  final dynamic initialItem;
  MediaPageView({
    Key key,
    this.mediaCollectionList,
    this.mediaList,
    this.fileList,
    this.callback,
    this.initialItem,
  }) : super(key: key);

  @override
  _MediaPageViewState createState() => _MediaPageViewState();
}

class _MediaPageViewState extends State<MediaPageView> {
  PageController _controller;
  Map<Media, CachedVideoPlayerController> videoPlayerControllerMapByMedia = {};

  @override
  void initState() {
    super.initState();
    var initialIndex;
    if (widget.mediaCollectionList != null) {
      initialIndex = widget.mediaCollectionList
          .indexWhere((element) => element == widget.initialItem);
    } else if (widget.mediaList != null) {
      initialIndex = widget.mediaList
          .indexWhere((element) => element == widget.initialItem);
    } else if (widget.fileList != null) {
      initialIndex = widget.fileList
          .indexWhere((element) => element == widget.initialItem);
    }
    _controller = PageController(initialPage: initialIndex);
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
          if (widget.callback != null) {
            return _buildPagerViewSliderFromCallback();
          } else if (widget.mediaCollectionList != null) {
            return _buildPagerViewSliderFromMediaCollection(
                widget.mediaCollectionList);
          } else if (widget.mediaList != null) {
            return _buildPagerViewSliderFromMedia(widget.mediaList);
          } else if (widget.fileList != null) {
            return _buildPagerViewSliderFromFile(widget.fileList);
          } else {
            return LoadingWidget();
          }
        },
      ),
    );
  }

  Widget _buildPagerViewSliderFromCallback() {
    return StreamBuilder<List<MediaCollection>>(
        stream: widget.callback().asStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _controller.jumpToPage(widget.mediaCollectionList
                .indexWhere((element) => element == widget.initialItem));
            return _buildPagerViewSliderFromMediaCollection(snapshot.data);
          } else {
            return EmptyWidget();
          }
        });
  }

  Widget _buildPagerViewSliderFromMediaCollection(
      List<MediaCollection> mediaCollectionList) {
    final List<Media> mediaList =
        mediaCollectionList.map((e) => e.media).toList();
    return _buildPagerViewSliderFromMedia(mediaList);
  }

  Widget _buildPagerViewSliderFromMedia(List<Media> mediaList) {
    final List<Media> videoList =
        mediaList.where((e) => e.mediaType == "VIDEO").toList();
    videoPlayerControllerMapByMedia = getVideoControllerMap(videoList);
    return PageView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        controller: _controller,
        itemCount: mediaList.length,
        itemBuilder: (BuildContext context, int index) {
          var media = mediaList[index];
          if (media.mediaType == "VIDEO") {
            return video(media);
          }
          return image(media);
        });
  }

  Widget image(Media photo) {
    return Hero(
      tag: photo.id,
      child: ClipRRect(
          child: CachedNetworkImage(
        imageUrl: photo.file.url,
        placeholder: (context, url) =>
            new Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => new Icon(Icons.error),
      )),
    );
  }

  Widget video(Media video) {
    return FutureBuilder(
      future: videoPlayerControllerMapByMedia[video].initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Hero(
              tag: video.id,
              child: VisibilityDetector(
                key: ValueKey(video.id),
                onVisibilityChanged: (info) {
                  if (info.visibleFraction == 0.0) {
                    if (videoPlayerControllerMapByMedia[video]
                        .value
                        .isPlaying) {
                      videoPlayerControllerMapByMedia[video].pause();
                    }
                  }
                },
                child: Stack(
                  children: [
                    CachedVideoPlayer(videoPlayerControllerMapByMedia[video]),
                    if (!videoPlayerControllerMapByMedia[video].value.isPlaying)
                      Center(
                          child: IconButton(
                              icon: Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 50,
                              ),
                              onPressed: () {
                                setState(() {
                                  videoPlayerControllerMapByMedia[video].play();
                                });
                              }))
                  ],
                ),
              ));
        }
        return LoadingWidget();
      },
    );
  }

  Widget _buildPagerViewSliderFromFile(List<ParseFile> parseFileList) {
    return PageView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        controller: _controller,
        itemCount: parseFileList.length,
        itemBuilder: (BuildContext context, int index) {
          return Hero(
            tag: parseFileList[index].file.path,
            child: ClipRRect(
              child: Image.file(parseFileList[index].file),
            ),
          );
        });
  }

  Map<Media, CachedVideoPlayerController> getVideoControllerMap(
      final List<Media> medialist) {
    Map<Media, CachedVideoPlayerController> videoPlayerControllerMap = {};
    medialist.forEach((element) {
      videoPlayerControllerMap[element] =
          CachedVideoPlayerController.network(element.file.url);
    });
    return videoPlayerControllerMap;
  }
}
