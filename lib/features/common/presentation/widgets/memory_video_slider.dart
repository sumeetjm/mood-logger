import 'package:flutter/material.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/widgets.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class MemoryVideoSlider extends StatefulWidget {
  final int initialIndex;
  final List<VideoOption> options;
  MemoryVideoSlider({this.options, this.initialIndex});
  @override
  _MemoryVideoSliderState createState() {
    return new _MemoryVideoSliderState();
  }
}

class _MemoryVideoSliderState extends State<MemoryVideoSlider> {
  PageController _controller;
  bool init = true;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildingImageSlider();
  }

  Widget _buildingImageSlider() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildPagerViewSlider(),
    );
  }

  Widget _buildPagerViewSlider() {
    _controller = PageController(initialPage: widget.initialIndex);
    return PageView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        controller: _controller,
        itemCount: widget.options.length,
        itemBuilder: (BuildContext context, int index) {
          return FutureBuilder(
            future: widget.options[index].controller.initialize(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Hero(
                    tag: index,
                    child: VisibilityDetector(
                      key: ValueKey(widget.options[index].file.file.path),
                      onVisibilityChanged: (info) {
                        if (info.visibleFraction == 0.0) {
                          if (widget
                              .options[index].controller.value.isPlaying) {
                            widget.options[index].controller.pause();
                          }
                        }
                      },
                      child: Stack(
                        children: [
                          VideoPlayer(widget.options[index].controller),
                          if (!widget.options[index].controller.value.isPlaying)
                            Center(
                                child: IconButton(
                                    icon: Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 50,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        widget.options[index].controller.play();
                                      });
                                    }))
                        ],
                      ),
                    ));
              }
              return LoadingWidget();
            },
          );
        });
  }
}

class VideoOption {
  final ParseFile file;
  final VideoPlayerController controller;

  VideoOption({
    @required this.file,
    @required this.controller,
  }) {
    controller.setLooping(true);
    controller.setVolume(1.0);
  }

  static List<VideoOption> listFrom({
    @required List<ParseFile> source,
  }) =>
      source
          .asMap()
          .map((index, item) => MapEntry(
              index,
              VideoOption(
                file: item,
                controller: VideoPlayerController.file(item.file),
              )))
          .values
          .toList()
          .cast<VideoOption>();
}
