import 'dart:io';

import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:mood_manager/features/common/data/models/media_collection_parse.dart';
import 'package:mood_manager/features/common/data/models/media_collection_mapping_parse.dart';
import 'package:mood_manager/features/common/data/models/media_parse.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection_mapping.dart';
import 'package:mood_manager/features/common/presentation/widgets/media_page_view.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:multi_media_picker/multi_media_picker.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageGridView extends StatefulWidget {
  final List<MediaCollectionMapping> imageMediaCollectionList;
  ImageGridView({
    Key key,
    this.imageMediaCollectionList,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _ImageGridViewState();
}

class _ImageGridViewState extends State<ImageGridView> {
  final controller = DragSelectGridViewController();
  final List<ParseFile> selectedImages = [];
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

  void delete() {
    for (final index in controller.value.selectedIndexes) {
      var removed = widget.imageMediaCollectionList.removeAt(index);
      removed.media.file.file?.delete();
      removed.media.file.delete();
      removed.media.thumbnail.file?.delete();
      removed.media.thumbnail.delete();
    }
    controller.clear();
    if (widget.imageMediaCollectionList.isEmpty) {
      Navigator.of(context).pop(widget.imageMediaCollectionList);
    }
  }

  void selectAll() {
    controller.value =
        Selection(widget.imageMediaCollectionList.asMap().keys.toSet());
  }

  void deselectAll() {
    controller.clear();
  }

  void edit() async {
    final selectedMediaCollection =
        widget.imageMediaCollectionList[controller.value.selectedIndexes.first];
    final newFile = await cropImage(selectedMediaCollection.media.file.file);
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
                      Navigator.of(context)
                          .pop(widget.imageMediaCollectionList);
                    },
                  )),
                  Container(child: Text("Selected images")),
                  Container(
                    child: IconButton(
                        icon: Icon(
                          Icons.done,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          Navigator.of(context)
                              .pop(widget.imageMediaCollectionList);
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
                              widget.imageMediaCollectionList.length)
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

  Future<List<File>> _onImageButtonPressedMultiple(ImageSource source,
      {BuildContext context}) async {
    try {
      final pickedFileList = await MultiMediaPicker.pickImages(
        source: source,
      );

      if (pickedFileList != null && pickedFileList.isNotEmpty) {
        return pickedFileList;
      }
    } catch (e) {
      print(e);
    }
    return Future.value([]);
  }

  buildSelectableGrid() {
    return DragSelectGridView(
      //shrinkWrap: true,
      gridController: controller,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: widget.imageMediaCollectionList.length + 1,
      itemBuilder: (BuildContext context, int index, bool selected) {
        if (index == widget.imageMediaCollectionList.length) {
          return GestureDetector(
            onTap: () {
              showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Container(
                      child: Wrap(
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.camera),
                            title: Text('Camera'),
                            onTap: () async {
                              Navigator.of(context).pop();
                              _onImageButtonPressedMultiple(ImageSource.camera,
                                  context: context);
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.photo_library),
                            title: Text('Gallery'),
                            onTap: () async {
                              Navigator.of(context).pop();
                              final pickedFileList =
                                  await _onImageButtonPressedMultiple(
                                      ImageSource.gallery,
                                      context: context);
                              for (final pickedFile in pickedFileList) {
                                final thumbnailImage = img.copyResize(
                                    img.decodeImage(
                                        pickedFile.readAsBytesSync()),
                                    width: 200);
                                final thumbnailFile = File(
                                    (await tempDirectoryFuture).path +
                                        "/" +
                                        uuid.v1() +
                                        ".jpg");
                                thumbnailFile.writeAsBytesSync(
                                    img.encodeJpg(thumbnailImage));
                                final mediaCollectionParse =
                                    MediaCollectionMappingParse(
                                  collection: widget
                                          .imageMediaCollectionList.isNotEmpty
                                      ? widget.imageMediaCollectionList[0]
                                          .collection
                                          .incrementMediaCount()
                                      : MediaCollectionParse(
                                          mediaType: 'PHOTO',
                                          module: 'MEMORY',
                                          name: uuid.v1(),
                                          code: uuid.v1(),
                                          mediaCount: 1,
                                          user: (await ParseUser.currentUser())
                                              as ParseUser,
                                        ),
                                  media: MediaParse(
                                    file: ParseFile(pickedFile),
                                    mediaType: 'PHOTO',
                                    thumbnail: ParseFile(thumbnailFile),
                                  ),
                                );
                                widget.imageMediaCollectionList
                                    .add(mediaCollectionParse);
                              }
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
        if (selected || controller.value.selectedIndexes.isNotEmpty) {
          return SelectableImageItem(
            mediaCollection: widget.imageMediaCollectionList[index],
            selected: selected,
          );
        }
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return MediaPageView(
                initialIndex: index,
                mediaCollectionList: widget.imageMediaCollectionList,
              );
            }));
          },
          onDoubleTap: () async {
            final selectedMediaCollection =
                widget.imageMediaCollectionList[index];
            final newFile = await cropImage((await widget
                    .imageMediaCollectionList[index].media.file
                    .download())
                .file);
            if (newFile != null) {
              final newThumbnailFile = File(
                  (await tempDirectoryFuture).path + "/" + uuid.v1() + ".jpg");
              newThumbnailFile.writeAsBytesSync(img.encodeJpg(img.copyResize(
                  img.decodeImage(newFile.readAsBytesSync()),
                  width: 200)));
              selectedMediaCollection.media.file.delete();
              selectedMediaCollection.media.file?.file?.delete();
              selectedMediaCollection.media.file = ParseFile(newFile);
              selectedMediaCollection.media.thumbnail.delete();
              selectedMediaCollection.media.thumbnail?.file?.delete();
              selectedMediaCollection.media.thumbnail =
                  ParseFile(newThumbnailFile);
              setState(() {});
            }
          },
          child: SelectableImageItem(
            mediaCollection: widget.imageMediaCollectionList[index],
            selected: selected,
          ),
        );
      },
    );
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
  }) : super(key: key);

  bool selected;
  final MediaCollectionMapping mediaCollection;

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
          color: widget.selected ? Colors.blue : Colors.black,
        )),
        child: Hero(
          tag: widget.mediaCollection.media.tag,
          child: Image(
            image: widget.mediaCollection.media.thumbnailProvider,
          ),
        ));
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
