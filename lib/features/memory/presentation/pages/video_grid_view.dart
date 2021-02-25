import 'dart:io';

import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:mood_manager/features/common/data/models/media_collection_parse.dart';
import 'package:mood_manager/features/common/data/models/media_collection_mapping_parse.dart';
import 'package:mood_manager/features/common/data/models/media_parse.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection_mapping.dart';
import 'package:mood_manager/features/common/presentation/widgets/media_page_view.dart';
import 'package:mood_manager/features/common/presentation/widgets/video_trim_view.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:multi_media_picker/multi_media_picker.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:uuid/uuid.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

class VideoGridView extends StatefulWidget {
  final List<MediaCollectionMapping> videoMediaCollectionList;
  final ValueChanged<List<MediaCollectionMapping>> onChanged;
  VideoGridView({
    Key key,
    this.videoMediaCollectionList,
    this.onChanged,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _VideoGridViewState();
}

class _VideoGridViewState extends State<VideoGridView> {
  final controller = DragSelectGridViewController();
  Trimmer _trimmer = sl<Trimmer>();
  final Uuid uuid = sl<Uuid>();
  Future<Directory> tempDirectoryFuture;

  @override
  void initState() {
    super.initState();
    controller.addListener(scheduleRebuild);
    tempDirectoryFuture = getTemporaryDirectory();
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
      backgroundColor: Colors.black.withOpacity(0.7),
      body: Container(
        margin: EdgeInsets.fromLTRB(30, 60, 30, 60),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            color: Colors.white),
        //color: Colors.white,
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(child: BackButton()),
                  Container(child: Text("Selected videos")),
                  Container(
                    child: IconButton(
                        icon: Icon(
                          Icons.done,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          Navigator.of(context)
                              .pop(widget.videoMediaCollectionList);
                        }),
                  ),
                  Container(
                    child: PopupMenuButton(
                      elevation: 3.2,
                      onCanceled: () {
                        print('You have not chossed anything');
                      },
                      tooltip: 'This is tooltip',
                      onSelected: (fn) => fn(),
                      itemBuilder: (BuildContext context) {
                        final popupMap = {
                          if (controller.value.selectedIndexes.length == 1)
                            'Edit': edit,
                          if (controller.value.selectedIndexes.length > 0)
                            'Delete': delete,
                          if (controller.value.selectedIndexes.length > 0)
                            'Deselect All': deselectAll,
                          if (controller.value.selectedIndexes.length !=
                              widget.videoMediaCollectionList.length)
                            'Select All': selectAll
                        };
                        return popupMap.keys.map((key) {
                          return PopupMenuItem(
                            value: popupMap[key],
                            child: Text(key),
                          );
                        }).toList();
                      },
                    ),
                  )
                ],
              ),
            ),
            Expanded(child: buildSelectableGrid())
          ],
        ),
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
    for (final index in controller.value.selectedIndexes) {
      var removed = widget.videoMediaCollectionList.removeAt(index);
      removed.media?.file?.file?.delete();
      removed.media?.file?.delete();
    }
    controller.clear();
    if (widget.videoMediaCollectionList.isEmpty) {
      Navigator.of(context).pop(widget.videoMediaCollectionList);
    }
    widget.onChanged(widget.videoMediaCollectionList);
  }

  void selectAll() {
    controller.value =
        Selection(widget.videoMediaCollectionList.asMap().keys.toSet());
  }

  void deselectAll() {
    controller.clear();
  }

  void edit() async {
    await _trimmer.loadVideo(
      videoFile: (await widget
              .videoMediaCollectionList[controller.value.selectedIndexes.first]
              .media
              .file
              .download())
          .file,
    );
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return VideoTrimView(
          trimmer: _trimmer,
          saveCallback: (value) async {
            var selectedMediaCollection = widget.videoMediaCollectionList[
                controller.value.selectedIndexes.first];
            final newThumbnailFile = File(
                (await tempDirectoryFuture).path + "/" + uuid.v1() + ".jpg");
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
              widget.onChanged(widget.videoMediaCollectionList);
            });
          });
    }));
    widget.onChanged(widget.videoMediaCollectionList);
  }

  buildSelectableGrid() {
    return DragSelectGridView(
      gridController: controller,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: widget.videoMediaCollectionList.length + 1,
      itemBuilder: (BuildContext context, int index, bool selected) {
        if (index == widget.videoMediaCollectionList.length) {
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
                              final pickedFileList =
                                  await _onVideoButtonPressedMultiple(
                                      ImageSource.gallery,
                                      context: context);

                              for (final pickedFile in pickedFileList) {
                                final thumbnailFile = File(
                                  (await tempDirectoryFuture).path +
                                      "/" +
                                      uuid.v1() +
                                      ".jpg",
                                );
                                await VideoThumbnail.thumbnailFile(
                                  video: pickedFile.path,
                                  thumbnailPath: thumbnailFile.path,
                                  imageFormat: ImageFormat.JPEG,
                                  maxHeight:
                                      200, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
                                  quality: 50,
                                );
                                final mediaCollectionParse =
                                    MediaCollectionMappingParse(
                                  collection:
                                      widget.videoMediaCollectionList.isNotEmpty
                                          ? widget.videoMediaCollectionList[0]
                                              .collection
                                              .incrementMediaCount()
                                          : MediaCollectionParse(
                                              mediaType: 'VIDEO',
                                              module: 'MEMORY',
                                              name: uuid.v1(),
                                              code: uuid.v1(),
                                              mediaCount: 1,
                                            ),
                                  media: MediaParse(
                                    file: ParseFile(pickedFile),
                                    mediaType: 'VIDEO',
                                    thumbnail: ParseFile(thumbnailFile),
                                  ),
                                );
                                widget.videoMediaCollectionList
                                    .add(mediaCollectionParse);
                              }
                              setState(() {
                                widget
                                    .onChanged(widget.videoMediaCollectionList);
                              });
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
        if (selected || controller.value.selectedIndexes.isNotEmpty) {
          return SelectableVideoItem(
            mediaCollection: widget.videoMediaCollectionList[index],
            selected: selected,
          );
        }
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return MediaPageView(
                initialIndex: index,
                mediaCollectionList: widget.videoMediaCollectionList,
              );
            }));
          },
          onDoubleTap: () async {
            await _trimmer.loadVideo(
              videoFile: (await widget
                      .videoMediaCollectionList[index].media.file
                      .download())
                  .file,
            );
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return VideoTrimView(
                  trimmer: _trimmer,
                  saveCallback: (value) async {
                    final selectedMediaCollection =
                        widget.videoMediaCollectionList[index];
                    final newThumbnailFile = File(
                        (await tempDirectoryFuture).path +
                            "/" +
                            uuid.v1() +
                            ".jpg");
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
                      widget.onChanged(widget.videoMediaCollectionList);
                    });
                  });
            }));
          },
          child: SelectableVideoItem(
            mediaCollection: widget.videoMediaCollectionList[index],
            selected: selected,
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
    @required this.selected,
    @required this.mediaCollection,
  }) : super(key: key);

  final MediaCollectionMapping mediaCollection;
  bool selected;

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
        tag: widget.mediaCollection.media.tag,
        child: Container(
          child: Image(
            image: widget.mediaCollection.media.thumbnailProvider,
          ),
        ),
      ),
    );
  }
}
