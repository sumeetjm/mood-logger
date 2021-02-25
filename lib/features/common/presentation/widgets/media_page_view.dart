import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';
import 'package:mood_manager/features/common/domain/entities/media.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection_mapping.dart';
import 'package:mood_manager/features/common/presentation/widgets/empty_widget.dart';
import 'package:mood_manager/features/common/presentation/widgets/loading_widget.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:visibility_detector/visibility_detector.dart';

class MediaPageView extends StatefulWidget {
  final List<MediaCollectionMapping> mediaCollectionList;
  final List<Media> mediaList;
  final List<ParseFile> fileList;
  final Future<List<MediaCollectionMapping>> future;
  final int initialIndex;
  final MediaCollectionMapping initialItem;
  MediaPageView({
    Key key,
    this.mediaCollectionList,
    this.mediaList,
    this.fileList,
    this.future,
    this.initialIndex,
    this.initialItem,
  }) : super(key: key);

  @override
  _MediaPageViewState createState() => _MediaPageViewState();
}

class _MediaPageViewState extends State<MediaPageView> {
  PageController _controller;
  Map<Media, MapEntry<Future, CachedVideoPlayerController>>
      videoPlayerControllerMap = {};

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex ?? 0);
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
            return _buildPagerViewSliderFromMediaCollection(
                widget.mediaCollectionList);
          } else if (widget.mediaList != null) {
            return _buildPagerViewSliderFromMedia(widget.mediaList);
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
      List<MediaCollectionMapping> mediaCollectionList) {
    final List<Media> mediaList =
        mediaCollectionList.map((e) => e.media).toList();
    return _buildPagerViewSliderFromMedia(mediaList);
  }

  Widget _buildPagerViewSliderFromMedia(List<Media> mediaList) {
    final List<Media> videoList =
        mediaList.where((e) => e.mediaType == "VIDEO").toList();
    videoPlayerControllerMap = getVideoControllerMapByMedia(videoList);
    return PageView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        controller: _controller,
        itemCount: mediaList.length,
        itemBuilder: (BuildContext context, int index) {
          final media = mediaList[index];
          if (media.mediaType == "VIDEO") {
            return videoFromMedia(media, index);
          }
          return imageFromMedia(media, index);
        });
  }

  Widget imageFromMedia(Media photo, int index) {
    return Hero(
      tag: photo.tag,
      child: ClipRRect(
        child: photo.imageProvider,
      ),
    );
  }

  Widget videoFromMedia(Media video, int index) {
    return FutureBuilder(
      future: videoPlayerControllerMap[video].key,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Hero(
              tag: video.tag,
              child: VisibilityDetector(
                key: ValueKey(video.id),
                onVisibilityChanged: (info) {
                  if (info.visibleFraction == 0.0) {
                    if (videoPlayerControllerMap[video].value.value.isPlaying) {
                      videoPlayerControllerMap[video].value.pause();
                    }
                  }
                },
                child: GestureDetector(
                  onTap: () {
                    if (videoPlayerControllerMap[video].value.value.isPlaying) {
                      videoPlayerControllerMap[video].value.pause();
                    } else {
                      videoPlayerControllerMap[video].value.play();
                    }
                  },
                  child:
                      CachedVideoPlayer(videoPlayerControllerMap[video].value),
                ),
              ));
        }
        return LoadingWidget();
      },
    );
  }

  Map<Media, MapEntry<Future, CachedVideoPlayerController>>
      getVideoControllerMapByMedia(final List<Media> mediaList) {
    return Map.fromEntries(mediaList.map((e) {
      final cachedVideoPlayerController = e.videoController;
      final initializeFuture = cachedVideoPlayerController.initialize();
      return MapEntry(
          e, MapEntry(initializeFuture, cachedVideoPlayerController));
    }));
  }
}
