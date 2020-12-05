import 'dart:io';

import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:mood_manager/features/common/presentation/widgets/loading_widget.dart';
import 'package:mood_manager/features/common/presentation/widgets/memory_image_slider.dart';
import 'package:mood_manager/features/common/presentation/widgets/memory_video_slider.dart';
import 'package:mood_manager/features/common/presentation/widgets/video_trim_view.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:multi_media_picker/multi_media_picker.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

class VideoGridView extends StatefulWidget {
  final Map<String, ParseFile> videosMap;
  List<String> thumbnailPathList;
  final ValueChanged<Map<String, ParseFile>> onChanged;
  VideoGridView({
    Key key,
    this.videosMap,
    this.onChanged,
  }) : super(key: key) {
    thumbnailPathList = videosMap.keys.toList();
  }
  @override
  State<StatefulWidget> createState() => _VideoGridViewState();
}

class _VideoGridViewState extends State<VideoGridView> {
  final controller = DragSelectGridViewController();
  final List<ParseFile> selectedVideos = [];
  Trimmer _trimmer = sl<Trimmer>();
  final Uuid uuid = sl<Uuid>();

  @override
  void initState() {
    super.initState();
    controller.addListener(scheduleRebuild);
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
        title: Text("Selected videos"),
        actions: [
          IconButton(
              icon: Icon(
                Icons.done,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          PopupMenuButton(
            elevation: 3.2,
            onCanceled: () {
              print('You have not chossed anything');
            },
            tooltip: 'This is tooltip',
            onSelected: (fn) {
              fn();
            },
            itemBuilder: (BuildContext context) {
              final popupMap = {
                if (controller.value.selectedIndexes.length == 1) 'Edit': edit,
                if (controller.value.selectedIndexes.length > 0)
                  'Delete': delete,
                if (controller.value.selectedIndexes.length > 0)
                  'Deselect All': deselectAll,
                if (controller.value.selectedIndexes.length !=
                    widget.videosMap.length)
                  'Select All': selectAll
              };
              return popupMap.keys.map((key) {
                return PopupMenuItem(
                  value: popupMap[key],
                  child: Text(key),
                );
              }).toList();
            },
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: buildSelectableGrid(),
      ),
    );
  }

  Future<List<File>> _onVideoButtonPressedMultiple(ImageSource source,
      {BuildContext context}) async {
    final pickedFile = await MultiMediaPicker.pickVideo(source: source);
    if (pickedFile != null) {
      return [pickedFile];
    }
    return [];
  }

  void delete() {
    for (final thumbnailFilePath in controller.value.selectedIndexes
        .map((e) => widget.thumbnailPathList[e])
        .toList()) {
      widget.videosMap.remove(thumbnailFilePath);
      File(thumbnailFilePath).deleteSync();
      widget.thumbnailPathList.remove(thumbnailFilePath);
    }
    controller.clear();
    if (widget.videosMap.isEmpty) {
      Navigator.of(context).pop();
    }
  }

  void selectAll() {
    controller.value = Selection(widget.thumbnailPathList.asMap().keys.toSet());
  }

  void deselectAll() {
    controller.clear();
  }

  void edit() async {
    await _trimmer.loadVideo(
        videoFile: File(widget
            .videosMap[widget
                .thumbnailPathList[controller.value.selectedIndexes.first]]
            .file
            .path));
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return VideoTrimView(
          trimmer: _trimmer,
          saveCallback: (value) async {
            final thumbnailFile = File(widget
                .thumbnailPathList[controller.value.selectedIndexes.first]);
            final newThumbnailFile =
                File(thumbnailFile.parent.path + "/" + uuid.v1() + ".jpg");
            await VideoThumbnail.thumbnailFile(
              video: value.path,
              thumbnailPath: newThumbnailFile.path,
              imageFormat: ImageFormat.JPEG,
              maxHeight:
                  120, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
              quality: 50,
            );
            widget.videosMap.remove(thumbnailFile.path);
            thumbnailFile.deleteSync();
            setState(() {
              widget.videosMap[newThumbnailFile.path] = ParseFile(value);
              widget.onChanged(widget.videosMap);
            });
          });
    }));
  }

  buildSelectableGrid() {
    return DragSelectGridView(
      gridController: controller,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: widget.videosMap.length + 1,
      itemBuilder: (BuildContext context, int index, bool selected) {
        if (index == widget.videosMap.length) {
          return GestureDetector(
            onTap: () {
              showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Container(
                      child: Wrap(
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.videocam),
                            title: Text('Video Camera'),
                            onTap: () async {
                              Navigator.of(context).pop();
                              _onVideoButtonPressedMultiple(ImageSource.camera,
                                  context: context);
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.photo_library),
                            title: Text('Gallery'),
                            onTap: () async {
                              Navigator.of(context).pop();
                              final cacheDir = await getTemporaryDirectory();
                              final pickedFileList =
                                  await _onVideoButtonPressedMultiple(
                                      ImageSource.gallery,
                                      context: context);

                              for (final pickedFile in pickedFileList) {
                                final newThumbnailFile = File(
                                    cacheDir.path + "/" + uuid.v1() + ".jpg");
                                await VideoThumbnail.thumbnailFile(
                                  video: pickedFile.path,
                                  thumbnailPath: newThumbnailFile.path,
                                  imageFormat: ImageFormat.JPEG,
                                  maxHeight:
                                      120, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
                                  quality: 50,
                                );
                                widget.videosMap[newThumbnailFile.path] =
                                    ParseFile(pickedFile);
                                widget.thumbnailPathList =
                                    widget.videosMap.keys.toList();
                              }
                              widget.onChanged(widget.videosMap);
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    );
                  });
            },
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.grey)),
              child: Icon(Icons.add),
            ),
          );
        }
        final videoController = VideoPlayerController.file(
            widget.videosMap[widget.thumbnailPathList[index]].file);
        if (selected || controller.value.selectedIndexes.isNotEmpty) {
          return SelectableVideoItem(
            image: ParseFile(File(widget.thumbnailPathList[index])),
            index: index,
            selected: selected,
            controller: videoController,
          );
        }
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return MemoryVideoSlider(
                initialIndex: index,
                options: VideoOption.listFrom(
                    source: widget.videosMap.values.toList()),
              );
            }));
          },
          onDoubleTap: () async {
            await _trimmer.loadVideo(
                videoFile: File(widget
                    .videosMap[widget.thumbnailPathList[index]].file.path));
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return VideoTrimView(
                  trimmer: _trimmer,
                  saveCallback: (value) async {
                    final thumbnailFile = File(widget.thumbnailPathList[index]);
                    final newThumbnailFile = File(
                        thumbnailFile.parent.path + "/" + uuid.v1() + ".jpg");
                    await VideoThumbnail.thumbnailFile(
                      video: value.path,
                      thumbnailPath: newThumbnailFile.path,
                      imageFormat: ImageFormat.JPEG,
                      maxHeight:
                          120, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
                      quality: 50,
                    );
                    widget.videosMap.remove(thumbnailFile.path);
                    thumbnailFile.deleteSync();
                    setState(() {
                      widget.videosMap[newThumbnailFile.path] =
                          ParseFile(value);
                      widget.onChanged(widget.videosMap);
                    });
                  });
            }));
          },
          child: SelectableVideoItem(
            image: ParseFile(File(widget.thumbnailPathList[index])),
            index: index,
            selected: selected,
            controller: videoController,
          ),
        );
      },
    );
  }
}

// ignore: must_be_immutable
class SelectableVideoItem extends StatefulWidget {
  SelectableVideoItem({
    Key key,
    @required this.index,
    @required this.selected,
    @required this.image,
    @required this.controller,
  }) : super(key: key);

  final int index;
  final VideoPlayerController controller;
  bool selected;
  final ParseFile image;

  @override
  _SelectableVideoItemState createState() => _SelectableVideoItemState();
}

class _SelectableVideoItemState extends State<SelectableVideoItem>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildGridItem(context);
  }

  Widget buildGridItem(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
        width: widget.selected ? 2 : 1,
        color: widget.selected ? Colors.blue : Colors.black,
      )),
      child: Hero(
          tag: widget.index,
          child: FutureBuilder(
              future: widget.controller.initialize(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return LoadingWidget();
                }
                return Container(
                  child: Image.file(
                    widget.image.file,
                    fit: BoxFit.fill,
                  ),
                );
              })),
    );
  }
}
