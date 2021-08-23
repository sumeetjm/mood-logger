import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mood_manager/core/util/hex_color.dart';
import 'package:mood_manager/features/common/presentation/widgets/empty_widget.dart';
import 'package:video_trimmer/trim_editor.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:video_trimmer/video_viewer.dart';
import 'package:mood_manager/home.dart';

import '../../../../injection_container.dart';

class VideoTrimView extends StatefulWidget {
  final File file;
  VideoTrimView({this.file});
  @override
  _VideoTrimViewState createState() => _VideoTrimViewState();
}

class _VideoTrimViewState extends State<VideoTrimView> {
  Trimmer trimmer;
  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;
  bool _progressVisibility = false;
  Future<void> loadVideo;

  _saveVideo() async {
    setState(() {
      _progressVisibility = true;
    });

    final _value = await trimmer.saveTrimmedVideo(
        startValue: _startValue, endValue: _endValue);
    setState(() {
      _progressVisibility = false;
    });
    return _value;
  }

  @override
  initState() {
    super.initState();
    trimmer = sl<Trimmer>();
    loadVideo = trimmer.loadVideo(videoFile: widget.file);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trim Video"),
      ),
      body: FutureBuilder<void>(
          future: loadVideo,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return EmptyWidget();
            }
            return Center(
              child: Container(
                padding: EdgeInsets.only(bottom: 30.0),
                color: Colors.black,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Visibility(
                      visible: _progressVisibility,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.red,
                      ),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            HexColor.fromHex('#ec8a5e')),
                      ),
                      onPressed: _progressVisibility
                          ? null
                          : () async {
                              _saveVideo().then((outputPath) {
                                print('OUTPUT PATH: $outputPath');
                                Fluttertoast.showToast(
                                    gravity: ToastGravity.TOP,
                                    msg: 'Video Saved successfully',
                                    backgroundColor: Colors.red);
                                Navigator.of(appNavigatorContext(context))
                                    .pop(File(outputPath));
                              });
                            },
                      child: Text("Save"),
                    ),
                    Expanded(
                      child: VideoViewer(),
                    ),
                    Center(
                      child: TrimEditor(
                        showDuration: true,
                        //maxVideoLength: Duration(seconds: 5),
                        viewerHeight: 50.0,
                        viewerWidth: MediaQuery.of(context).size.width,
                        onChangeStart: (value) {
                          _startValue = value;
                        },
                        onChangeEnd: (value) {
                          _endValue = value;
                        },
                        onChangePlaybackState: (value) {
                          setState(() {
                            _isPlaying = value;
                          });
                        },
                      ),
                    ),
                    TextButton(
                      child: _isPlaying
                          ? Icon(
                              Icons.pause,
                              size: 80.0,
                              color: Colors.white,
                            )
                          : Icon(
                              Icons.play_arrow,
                              size: 80.0,
                              color: Colors.white,
                            ),
                      onPressed: () async {
                        bool playbackState = await trimmer.videPlaybackControl(
                          startValue: _startValue,
                          endValue: _endValue,
                        );
                        setState(() {
                          _isPlaying = playbackState;
                        });
                      },
                    )
                  ],
                ),
              ),
            );
          }),
    );
  }
}
