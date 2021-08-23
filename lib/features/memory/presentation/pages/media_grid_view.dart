import 'dart:io';

import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mood_manager/core/constants/app_constants.dart';
import 'package:mood_manager/features/common/data/datasources/media_file_service.dart';
import 'package:mood_manager/features/common/data/models/media_collection_parse.dart';
import 'package:mood_manager/features/common/data/models/media_collection_mapping_parse.dart';
import 'package:mood_manager/features/common/data/models/media_parse.dart';
import 'package:mood_manager/features/common/domain/entities/base.dart';
import 'package:mood_manager/features/common/domain/entities/base_states.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection_mapping.dart';
import 'package:mood_manager/features/common/presentation/widgets/media_page_view.dart';
import 'package:mood_manager/features/common/presentation/widgets/video_trim_view.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mood_manager/home.dart';

class MediaGridView extends StatefulWidget {
  List<MediaCollectionMapping> mediaCollectionList;
  final ValueChanged<List<MediaCollectionMapping>> onChanged;
  final MediaCollectionMapping toBeAddedMediaCollectionMapping;
  final String mediaType;
  MediaGridView({
    Key key,
    this.mediaCollectionList,
    this.onChanged,
    this.mediaType,
    this.toBeAddedMediaCollectionMapping,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _MediaGridViewState();
}

class _MediaGridViewState extends State<MediaGridView> {
  final controller = DragSelectGridViewController();
  final Uuid uuid = sl<Uuid>();
  final MediaFileService mediaFileService = sl<MediaFileService>();
  // ignore: non_constant_identifier_names
  Future<Directory> TEMP_DIR;

  @override
  void initState() {
    super.initState();
    controller.addListener(scheduleRebuild);
    TEMP_DIR = getTemporaryDirectory();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (widget.toBeAddedMediaCollectionMapping != null) {
        final toEditFile =
            (await widget.toBeAddedMediaCollectionMapping.media.file.download())
                .file;
        if (widget.toBeAddedMediaCollectionMapping.media.mediaType == 'VIDEO') {
          File editedFile;
          if (AppConstants.allowVideoTrimming &&
              AppConstants.trimVideoBeforeAdd) {
            editedFile = await Navigator.of(appNavigatorContext(context))
                .push(MaterialPageRoute(builder: (context) {
              return VideoTrimView(
                file: toEditFile,
              );
            }));
          } else {
            editedFile = toEditFile;
          }
          if (editedFile != null) {
            File newEditedFile = editedFile.copySync((await TEMP_DIR).path +
                "/" +
                uuid.v1() +
                editedFile.path.substring(editedFile.path.lastIndexOf(".")));
            editedFile.delete();
            widget.toBeAddedMediaCollectionMapping.media.file =
                ParseFile(newEditedFile);
            await widget.toBeAddedMediaCollectionMapping.media
                .setThumbnail((await TEMP_DIR).path, uuid.v1());
            await widget.toBeAddedMediaCollectionMapping.media
                .setDominantColor();
            widget.mediaCollectionList
                .add(widget.toBeAddedMediaCollectionMapping);
            setState(() {
              widget.onChanged?.call(widget.mediaCollectionList);
            });
          }
          if (widget.mediaCollectionList.isEmpty) {
            Navigator.of(appNavigatorContext(context)).pop();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    controller.removeListener(scheduleRebuild);
    super.dispose();
  }

  void scheduleRebuild() => setState(() {});

  void delete() async {
    final removedList = controller.value.selectedIndexes
        .map((e) => widget.mediaCollectionList[e])
        .toList();
    for (final removed in removedList) {
      widget.mediaCollectionList.remove(removed);
      await removed.media.delete();
    }
    controller.clear();
    if (widget.mediaCollectionList.isEmpty) {
      Navigator.of(appNavigatorContext(context)).pop([]);
    }
    widget.onChanged?.call(widget.mediaCollectionList);
  }

  void selectAll() {
    controller.value =
        Selection(widget.mediaCollectionList.asMap().keys.toSet());
  }

  void deselectAll() {
    controller.clear();
  }

  void editPhoto(MediaCollectionMapping selectedMediaCollection) async {
    var toEditFile = await selectedMediaCollection.media.mediaFile();
    final editedFile = await cropImage(toEditFile);
    if (editedFile != null) {
      await selectedMediaCollection.media.delete();
      selectedMediaCollection.media.file = ParseFile(editedFile);
      await selectedMediaCollection.media
          .setThumbnail((await TEMP_DIR).path, uuid.v1());
      await selectedMediaCollection.media.setDominantColor();
      setState(() {
        widget.onChanged.call(widget.mediaCollectionList);
      });
    }
  }

  void editVideo(MediaCollectionMapping selectedMediaCollection) async {
    final toEditFile = await selectedMediaCollection.media.mediaFile();
    File editedFile = await Navigator.of(appNavigatorContext(context))
        .push(MaterialPageRoute(builder: (context) {
      return VideoTrimView(
        file: toEditFile,
      );
    }));
    if (editedFile != null) {
      editedFile = BaseUtil.renameFileSync(editedFile, uuid.v1());
      await selectedMediaCollection.media.delete();
      selectedMediaCollection.media.file = ParseFile(editedFile);
      await selectedMediaCollection.media
          .setThumbnail((await TEMP_DIR).path, uuid.v1());
      await selectedMediaCollection.media.setDominantColor();
      setState(() {
        widget.onChanged.call(widget.mediaCollectionList);
      });
    }
  }

  void edit({int i}) async {
    final index = i ?? controller.value.selectedIndexes.first;
    final selectedMediaCollection = widget.mediaCollectionList[index];
    if (selectedMediaCollection.media.mediaType == 'PHOTO') {
      editPhoto(selectedMediaCollection);
    } else {
      editVideo(selectedMediaCollection);
    }
  }

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
                  Container(child: BackButton(
                    onPressed: () {
                      Navigator.of(appNavigatorContext(context))
                          .pop(widget.mediaCollectionList);
                    },
                  )),
                  Container(
                      child: Text(
                          "Selected ${widget.mediaType == 'PHOTO' ? 'images' : 'videos'}")),
                  Container(
                    child: IconButton(
                        icon: Icon(
                          Icons.done,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          Navigator.of(appNavigatorContext(context))
                              .pop(widget.mediaCollectionList);
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
                          if (controller.value.selectedIndexes.length == 1 &&
                              isEditAllowed())
                            'Edit': edit,
                          if (controller.value.selectedIndexes.length > 0)
                            'Delete': delete,
                          if (controller.value.selectedIndexes.length > 0)
                            'Deselect All': deselectAll,
                          if (controller.value.selectedIndexes.length !=
                              widget.mediaCollectionList.length)
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

  isEditAllowed() {
    return ((widget.mediaCollectionList[controller.value.selectedIndexes.first]
                    .media.mediaType ==
                'PHOTO' &&
            AppConstants.allowImageCropping) ||
        (widget.mediaCollectionList[controller.value.selectedIndexes.first]
                    .media.mediaType ==
                'VIDEO' &&
            AppConstants.allowVideoTrimming));
  }

  buildSelectableGrid() {
    return AnimationLimiter(
      child: DragSelectGridView(
        //shrinkWrap: true,
        gridController: controller,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: widget.mediaCollectionList.length + 1,
        itemBuilder: (BuildContext context, int index, bool selected) {
          if (index == widget.mediaCollectionList.length) {
            return AnimationConfiguration.staggeredGrid(
                columnCount: 2,
                position: index,
                duration: const Duration(milliseconds: 500),
                child: ScaleAnimation(
                    child: FadeInAnimation(
                        child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Container(
                            child: Wrap(
                              children: widget.mediaType == 'PHOTO'
                                  ? <Widget>[
                                      ListTile(
                                          leading: Icon(Icons.photo_album),
                                          title: Text('Album'),
                                          onTap: () async {
                                            Navigator.of(appNavigatorContext(
                                                    context))
                                                .pop();
                                            final pickedFileList =
                                                await mediaFileService
                                                    .pickFilesFromAlbum(
                                                        mediaType:
                                                            widget.mediaType,
                                                        context: context);
                                            if ((pickedFileList ?? [])
                                                .isNotEmpty) {
                                              handleFuture<void>(() => select(
                                                  pickedFileList,
                                                  mediaType: widget.mediaType));
                                            }
                                          }),
                                      ListTile(
                                        leading: Icon(Icons.photo_library),
                                        title: Text('Gallery'),
                                        onTap: () async {
                                          Navigator.of(context).pop();
                                          final pickedFileList =
                                              await mediaFileService.pickFiles(
                                                  type: FileType.image);
                                          if ((pickedFileList ?? [])
                                              .isNotEmpty) {
                                            handleFuture<void>(() => select(
                                                pickedFileList,
                                                mediaType: widget.mediaType));
                                          }
                                        },
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.camera),
                                        title: Text('Camera'),
                                        onTap: () async {
                                          Navigator.of(context).pop();
                                          final pickedFile =
                                              await mediaFileService
                                                  .pickFileFromCamera(
                                                      context: context,
                                                      mediaType:
                                                          widget.mediaType);
                                          if (pickedFile != null) {
                                            handleFuture<void>(() => select(
                                                [pickedFile],
                                                mediaType: widget.mediaType));
                                          }
                                        },
                                      ),
                                    ]
                                  : <Widget>[
                                      ListTile(
                                        leading: Icon(Icons.video_collection),
                                        title: Text('Album'),
                                        onTap: () async {
                                          Navigator.of(
                                                  appNavigatorContext(context))
                                              .pop();
                                          final pickedFileList =
                                              await mediaFileService
                                                  .pickFilesFromAlbum(
                                                      mediaType:
                                                          widget.mediaType,
                                                      context: context);
                                          if ((pickedFileList ?? [])
                                              .isNotEmpty) {
                                            handleFuture<void>(() => select(
                                                pickedFileList,
                                                mediaType: widget.mediaType));
                                          }
                                        },
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.photo_library),
                                        title: Text('Gallery'),
                                        onTap: () async {
                                          Navigator.of(
                                                  appNavigatorContext(context))
                                              .pop();
                                          final pickedFileList =
                                              await mediaFileService.pickFiles(
                                                  type: FileType.video);
                                          if ((pickedFileList ?? [])
                                              .isNotEmpty) {
                                            handleFuture<void>(() => select(
                                                pickedFileList,
                                                mediaType: widget.mediaType));
                                          }
                                        },
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.videocam),
                                        title: Text('Video Camera'),
                                        onTap: () async {
                                          Navigator.of(context).pop();
                                          final pickedFile =
                                              await mediaFileService
                                                  .pickFileFromCamera(
                                                      context: context,
                                                      mediaType:
                                                          widget.mediaType);
                                          if (pickedFile != null) {
                                            handleFuture<void>(() => select(
                                                [pickedFile],
                                                mediaType: widget.mediaType));
                                          }
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
                ))));
          }
          if (selected || controller.value.selectedIndexes.isNotEmpty) {
            return AnimationConfiguration.staggeredGrid(
                columnCount: 2,
                position: index,
                duration: const Duration(milliseconds: 500),
                child: ScaleAnimation(
                    child: FadeInAnimation(
                        child: SelectableImageItem(
                  selectColor: Theme.of(context).accentColor,
                  mediaCollection: widget.mediaCollectionList[index],
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
                    onTap: () {
                      Navigator.of(appNavigatorContext(context))
                          .push(MaterialPageRoute(builder: (context) {
                        return MediaPageView(
                          showAddToCollection: false,
                          initialIndex: index,
                          mediaCollectionList: widget.mediaCollectionList,
                          saveMediaCollectionMappingList:
                              (mediaCollectionMappingList) {
                            setState(() {
                              widget.mediaCollectionList =
                                  mediaCollectionMappingList
                                      .where((element) => element.isActive)
                                      .toList();
                              widget.onChanged
                                  ?.call(widget.mediaCollectionList);
                            });
                          },
                        );
                      }));
                    },
                    onDoubleTap: () async {
                      if (((widget.mediaCollectionList[index].media.mediaType ==
                                  'PHOTO' &&
                              AppConstants.allowImageCropping) ||
                          (widget.mediaCollectionList[index].media.mediaType ==
                                  'VIDEO' &&
                              AppConstants.allowVideoTrimming))) {
                        edit(i: index);
                      }
                    },
                    child: SelectableImageItem(
                      selectColor: Theme.of(context).accentColor,
                      mediaCollection: widget.mediaCollectionList[index],
                      selected: selected,
                    ),
                  ))));
        },
      ),
    );
  }

  Future<void> select(List<File> fileList, {String mediaType}) async {
    if (fileList.isEmpty) {
      return;
    }
    for (final pickedFile in fileList) {
      var mediaParse = MediaParse(
        file: ParseFile(pickedFile),
        mediaType: mediaType,
      );
      await mediaParse.setThumbnail((await TEMP_DIR).path, uuid.v1());
      await mediaParse.setDominantColor();
      final mediaCollectionParse = MediaCollectionMappingParse(
        collection: widget.mediaCollectionList.isNotEmpty
            ? widget.mediaCollectionList[0].collection
            : MediaCollectionParse(
                mediaType: mediaType,
                module: 'MEMORY',
                name: uuid.v1(),
                code: uuid.v1(),
                user: (await ParseUser.currentUser()) as ParseUser,
              ),
        media: mediaParse,
      );
      widget.mediaCollectionList.add(mediaCollectionParse);
    }
    setState(() {
      widget.onChanged.call(widget.mediaCollectionList);
    });
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
}

// ignore: must_be_immutable
class SelectableImageItem extends StatefulWidget {
  SelectableImageItem({
    Key key,
    @required this.mediaCollection,
    @required this.selected,
    this.selectColor = Colors.blue,
  }) : super(key: key);

  bool selected;
  final MediaCollectionMapping mediaCollection;
  final Color selectColor;

  @override
  _SelectableImageItemState createState() => _SelectableImageItemState();
}

class _SelectableImageItemState extends State<SelectableImageItem>
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
          color: widget.selected ? widget.selectColor : Colors.black,
        )),
        child: Hero(
          tag: widget.mediaCollection.media.tag(),
          child: Image(
            fit: BoxFit.cover,
            image: widget.mediaCollection.media.thumbnailProvider,
          ),
        ));
  }
}
