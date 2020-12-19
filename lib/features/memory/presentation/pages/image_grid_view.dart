import 'dart:io';

import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:mood_manager/features/common/presentation/widgets/media_page_view.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:multi_media_picker/multi_media_picker.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageGridView extends StatefulWidget {
  final Map<ParseFile, ParseFile> imagesMap;
  List<ParseFile> thumbnailList;
  final ValueChanged<Map<ParseFile, ParseFile>> onChanged;
  ImageGridView({
    Key key,
    this.imagesMap,
    this.onChanged,
  }) : super(key: key) {
    this.thumbnailList = imagesMap.keys.toList();
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
    for (final thumbnailFile in controller.value.selectedIndexes
        .map((e) => widget.thumbnailList[e])
        .toList()) {
      widget.imagesMap.remove(thumbnailFile);
      thumbnailFile.file.deleteSync();
      widget.thumbnailList.remove(thumbnailFile);
    }
    controller.clear();
    widget.onChanged(widget.imagesMap);
    if (widget.imagesMap.isEmpty) {
      Navigator.of(context).pop();
    }
  }

  void selectAll() {
    controller.value = Selection(widget.thumbnailList.asMap().keys.toSet());
  }

  void deselectAll() {
    controller.clear();
  }

  void edit() async {
    final selectedThumbnailPath =
        widget.thumbnailList[controller.value.selectedIndexes.first];
    final file = await cropImage(widget.imagesMap[selectedThumbnailPath].file);
    setState(() {
      final thumbnailFile = selectedThumbnailPath;
      final newThumbnailFile =
          File(thumbnailFile.file.parent.path + "/" + uuid.v1() + ".jpg");
      newThumbnailFile.writeAsBytesSync(img.encodeJpg(
          img.copyResize(img.decodeImage(file.readAsBytesSync()), width: 200)));
      widget.imagesMap.remove(thumbnailFile);
      thumbnailFile.file.deleteSync();
      final newThumbnailParseFile = ParseFile(newThumbnailFile);
      widget.thumbnailList[controller.value.selectedIndexes.first] =
          newThumbnailParseFile;
      widget.imagesMap[newThumbnailParseFile] = ParseFile(file);
    });
    widget.onChanged(widget.imagesMap);
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
                  Container(child: BackButton()),
                  Container(child: Text("Selected images")),
                  Container(
                    child: IconButton(
                        icon: Icon(
                          Icons.done,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
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
                                    width: 200);
                                final thumbnailFile = File(
                                    cacheDir.path + "/" + uuid.v1() + ".jpg");
                                thumbnailFile.writeAsBytesSync(
                                    img.encodeJpg(thumbnailImage));
                                widget.imagesMap[ParseFile(thumbnailFile)] =
                                    ParseFile(pickedFile);
                                widget.thumbnailList =
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
            image: widget.thumbnailList[index],
            value: widget.imagesMap[widget.thumbnailList[index]],
            selected: selected,
          );
        }
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return MediaPageView(
                initialItem: widget.imagesMap[widget.thumbnailList[index]],
                fileList: widget.imagesMap.values.toList(),
              );
            }));
          },
          onDoubleTap: () async {
            final croppedImage = await cropImage(
                widget.imagesMap[widget.thumbnailList[index]].file);
            if (croppedImage != null) {
              setState(() {
                final thumbnailFile = widget.thumbnailList[index];
                final newThumbnailFile = File(
                    thumbnailFile.file.parent.path + "/" + uuid.v1() + ".jpg");
                newThumbnailFile.writeAsBytesSync(img.encodeJpg(img.copyResize(
                    img.decodeImage(croppedImage.readAsBytesSync()),
                    width: 200)));
                widget.imagesMap.remove(thumbnailFile);
                thumbnailFile.file.deleteSync();
                var newThumbnailParseFile = ParseFile(newThumbnailFile);
                widget.thumbnailList[index] = newThumbnailParseFile;
                widget.imagesMap[newThumbnailParseFile] =
                    ParseFile(croppedImage);
                widget.onChanged(widget.imagesMap);
              });
            }
          },
          child: SelectableImageItem(
            image: widget.thumbnailList[index],
            value: widget.imagesMap[widget.thumbnailList[index]],
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
    @required this.value,
    @required this.selected,
    @required this.image,
  }) : super(key: key);

  final ParseFile value;
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
      child: Hero(
          tag: widget.value.file.path, child: Image.file(widget.image.file)),
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
