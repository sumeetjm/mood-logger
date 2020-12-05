import 'dart:io';

import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:mood_manager/features/common/presentation/widgets/memory_image_slider.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:multi_media_picker/multi_media_picker.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageGridView extends StatefulWidget {
  final Map<String, ParseFile> imagesMap;
  List<String> thumbnailPathList;
  final ValueChanged<Map<String, ParseFile>> onChanged;
  ImageGridView({
    Key key,
    this.imagesMap,
    this.onChanged,
  }) : super(key: key) {
    this.thumbnailPathList = imagesMap.keys.toList();
  }
  @override
  State<StatefulWidget> createState() => _ImageGridViewState();
}

class _ImageGridViewState extends State<ImageGridView> {
  final controller = DragSelectGridViewController();
  final List<ParseFile> selectedImages = [];
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

  void delete() {
    for (final thumbnailFilePath in controller.value.selectedIndexes
        .map((e) => widget.thumbnailPathList[e])
        .toList()) {
      widget.imagesMap.remove(thumbnailFilePath);
      File(thumbnailFilePath).deleteSync();
      widget.thumbnailPathList.remove(thumbnailFilePath);
    }
    controller.clear();
    if (widget.imagesMap.isEmpty) {
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
    final selectedThumbnailPath =
        widget.thumbnailPathList[controller.value.selectedIndexes.first];
    final file = await cropImage(widget.imagesMap[selectedThumbnailPath].file);
    setState(() {
      final thumbnailFile = File(selectedThumbnailPath);
      final newThumbnailFile =
          File(thumbnailFile.parent.path + "/" + uuid.v1() + ".jpg");
      newThumbnailFile.writeAsBytesSync(img.encodeJpg(
          img.copyResize(img.decodeImage(file.readAsBytesSync()), width: 120)));
      widget.imagesMap.remove(thumbnailFile.path);
      thumbnailFile.deleteSync();
      widget.thumbnailPathList[controller.value.selectedIndexes.first] =
          newThumbnailFile.path;
      widget.imagesMap[newThumbnailFile.path] = ParseFile(file);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Selected images"),
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
            onSelected: (fn) => fn(),
            itemBuilder: (BuildContext context) {
              final popupMap = {
                if (controller.value.selectedIndexes.length == 1) 'Edit': edit,
                if (controller.value.selectedIndexes.length > 0)
                  'Delete': delete,
                if (controller.value.selectedIndexes.length > 0)
                  'Deselect All': deselectAll,
                if (controller.value.selectedIndexes.length !=
                    widget.imagesMap.length)
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
      gridController: controller,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: widget.imagesMap.length + 1,
      itemBuilder: (BuildContext context, int index, bool selected) {
        if (index == widget.imagesMap.length) {
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
                              final cacheDir = await getTemporaryDirectory();
                              for (final pickedFile in pickedFileList) {
                                final thumbnailImage = img.copyResize(
                                    img.decodeImage(
                                        pickedFile.readAsBytesSync()),
                                    width: 120);
                                final thumbnailFile = File(
                                    cacheDir.path + "/" + uuid.v1() + ".jpg");
                                thumbnailFile.writeAsBytesSync(
                                    img.encodeJpg(thumbnailImage));
                                widget.imagesMap[thumbnailFile.path] =
                                    ParseFile(pickedFile);
                                widget.thumbnailPathList =
                                    widget.imagesMap.keys.toList();
                              }
                              widget.onChanged(widget.imagesMap);
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
            image: ParseFile(File(widget.thumbnailPathList[index])),
            index: index,
            selected: selected,
          );
        }
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return MemoryImageSlider(
                initialIndex: index,
                imagesMap: widget.imagesMap,
              );
            }));
          },
          onDoubleTap: () async {
            final croppedImage = await cropImage(
                widget.imagesMap[widget.thumbnailPathList[index]].file);
            if (croppedImage != null) {
              setState(() {
                final thumbnailFile = File(widget.thumbnailPathList[index]);
                final newThumbnailFile =
                    File(thumbnailFile.parent.path + "/" + uuid.v1() + ".jpg");
                newThumbnailFile.writeAsBytesSync(img.encodeJpg(img.copyResize(
                    img.decodeImage(croppedImage.readAsBytesSync()),
                    width: 120)));
                widget.imagesMap.remove(thumbnailFile.path);
                thumbnailFile.deleteSync();
                widget.thumbnailPathList[index] = newThumbnailFile.path;
                widget.imagesMap[newThumbnailFile.path] =
                    ParseFile(croppedImage);
                widget.onChanged(widget.imagesMap);
              });
            }
          },
          child: SelectableImageItem(
            image: ParseFile(File(widget.thumbnailPathList[index])),
            index: index,
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
    @required this.index,
    @required this.selected,
    @required this.image,
  }) : super(key: key);

  final int index;
  bool selected;
  final ParseFile image;

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
      child: Hero(tag: widget.index, child: Image.file(widget.image.file)),
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
