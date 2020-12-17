import 'dart:io';
import 'dart:ui';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:mood_manager/features/common/data/models/media_parse.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/common/presentation/pages/activity_selection_page.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:mood_manager/features/memory/presentation/pages/image_grid_view.dart';
import 'package:mood_manager/features/memory/presentation/pages/video_grid_view.dart';
import 'package:mood_manager/features/memory/presentation/widgets/transparent_page_route.dart';
import 'package:mood_manager/features/metadata/data/datasources/m_mood_remote_data_source.dart';
import 'package:mood_manager/features/common/data/models/collection_parse.dart';
import 'package:mood_manager/features/memory/data/models/memory_parse.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_mood.dart';
import 'package:mood_manager/features/common/presentation/widgets/date_selector.dart';
import 'package:mood_manager/features/common/presentation/widgets/mood_selection_dialog.dart';
import 'package:mood_manager/features/common/presentation/widgets/time_picker.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/widgets.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:multi_media_picker/multi_media_picker.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class MemoryFormView extends StatefulWidget {
  final Function saveCallback;

  MemoryFormView({Key key, this.saveCallback}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MemoryFormViewState();
}

class _MemoryFormViewState extends State<MemoryFormView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime date = DateTime.now();
  TimeOfDay time = TimeOfDay.now();
  List<MActivity> activityList = [];
  final TextEditingController noteController = TextEditingController();
  MMood mMood;
  Uuid uuid;
  Memory memory;
  Map<String, ParseFile> imageFileMapByThumbnail = {};
  Map<String, ParseFile> videoFileMapByThumbnail = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: ListView(
        children: [
          DateSelector(
              initialDate: date,
              selectDate: (DateTime date) {
                setState(() {
                  this.date = date;
                });
              }),
          TimePicker(
            selectedTime: time,
            selectTime: (time) {
              setState(() {
                this.time = time;
              });
            },
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                controller: noteController,
                minLines: 7,
                maxLines: 15,
                autocorrect: false,
                decoration: InputDecoration(
                  hintText: 'Write your story here',
                  filled: true,
                  fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
          OrientationBuilder(builder: (context, orientation) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 0, 15.0, 0),
              child: GridView.count(
                childAspectRatio: 1.25,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: orientation == Orientation.portrait ? 2 : 4,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                children: [
                  if (imageFileMapByThumbnail.isNotEmpty)
                    BlurImageGridItem(
                      context: context,
                      child: buildAddImageIconButtonItem(context),
                      imageList: imageFileMapByThumbnail.keys
                          .map((e) => ParseFile(File(e)))
                          .toList(),
                    ),
                  if (imageFileMapByThumbnail.isEmpty)
                    buildAddImageIconButtonItem(context),
                  if (videoFileMapByThumbnail.isNotEmpty)
                    BlurImageGridItem(
                      context: context,
                      child: buildAddVideoIconButtonItem(context),
                      imageList: videoFileMapByThumbnail.keys
                          .map((e) => ParseFile(File(e)))
                          .toList(),
                    ),
                  if (videoFileMapByThumbnail.isEmpty)
                    buildAddVideoIconButtonItem(context),
                  if (activityList.isNotEmpty)
                    BlurActivityGridItem(
                      context: context,
                      child: buildAddActivityIconButtonItem(),
                      activityList: activityList,
                    ),
                  if (activityList.isEmpty) buildAddActivityIconButtonItem(),
                  FutureBuilder<List<MMood>>(
                      initialData: [],
                      future: sl<MMoodRemoteDataSource>().getMMoodList(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data.isEmpty) {
                          return iconButton(
                              icon: Container(
                                  width: 20,
                                  height: 20,
                                  child: LoadingWidget()),
                              onPressed: () {});
                        }
                        return IconButtonItem(
                            icon: Column(
                              children: [
                                Container(
                                  width: 25,
                                  height: 50,
                                  child: Image.asset(
                                    'assets/smiley_face.png',
                                    height: 25,
                                  ),
                                ),
                                Text('Add Mood')
                              ],
                            ),
                            onPressed: () {
                              Navigator.of(_scaffoldKey.currentContext)
                                  .push(TransparentRoute(builder: (context) {
                                return MoodSelectionPage(
                                  moodList: snapshot.data,
                                  saveCallback: saveMood,
                                  selectedMood: mMood,
                                );
                              }));
                            });
                      }),
                ],
              ),
            );
          }),
          /*Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButtonItem(
                  icon: Column(
                    children: [
                      Container(
                          width: 25, height: 50, child: Icon(Icons.camera)),
                      Text('Add Photo'),
                    ],
                  ),
                  onPressed: () {
                    // loadAssets();
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Container(
                            child: Wrap(
                              children: <Widget>[
                                ListTile(
                                    leading: Icon(Icons.camera),
                                    title: Text('Camera'),
                                    onTap: () => {
                                          Navigator.of(context).pop(),
                                          _onImageButtonPressedMultiple(
                                              ImageSource.camera,
                                              context: context)
                                        }),
                                ListTile(
                                  leading: Icon(Icons.photo_library),
                                  title: Text('Gallery'),
                                  onTap: () => {
                                    Navigator.of(context).pop(),
                                    _onImageButtonPressedMultiple(
                                        ImageSource.gallery,
                                        context: context)
                                  },
                                ),
                              ],
                            ),
                          );
                        });
                  }),
              IconButtonItem(
                  icon: Column(
                    children: [
                      Container(
                          width: 25, height: 50, child: Icon(Icons.videocam)),
                      Text('Add Video'),
                    ],
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Container(
                            child: Wrap(
                              children: <Widget>[
                                ListTile(
                                    leading: Icon(Icons.videocam),
                                    title: Text('Video Camera'),
                                    onTap: () => {
                                          Navigator.of(context).pop(),
                                          _onVideoButtonPressedMultiple(
                                              ImageSource.camera,
                                              context: context)
                                        }),
                                ListTile(
                                  leading: Icon(Icons.video_library),
                                  title: Text('Gallery'),
                                  onTap: () => {
                                    Navigator.of(context).pop(),
                                    _onVideoButtonPressedMultiple(
                                        ImageSource.gallery,
                                        context: context)
                                  },
                                ),
                              ],
                            ),
                          );
                        });
                  }),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButtonItem(
                  icon: Column(
                    children: [
                      Container(
                        width: 25,
                        height: 50,
                        child: Image.asset(
                          'assets/activity.png',
                          height: 25,
                        ),
                      ),
                      Text('Add Activity')
                    ],
                  ),
                  onPressed: () {
                    Navigator.of(_scaffoldKey.currentContext)
                        .push(MaterialPageRoute(builder: (context) {
                      return ActivitySelectionPage(
                        selectedActivityList: activityList,
                        onChange: (value) {
                          activityList = value;
                        },
                      );
                    }));
                  }),
              FutureBuilder<List<MMood>>(
                  initialData: [],
                  future: sl<MMoodRemoteDataSource>().getMMoodList(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data.isEmpty) {
                      return iconButton(
                          icon: Container(
                              width: 20, height: 20, child: LoadingWidget()),
                          onPressed: () {});
                    }
                    return IconButtonItem(
                        icon: Column(
                          children: [
                            Container(
                              width: 25,
                              height: 50,
                              child: Image.asset(
                                'assets/smiley_face.png',
                                height: 25,
                              ),
                            ),
                            Text('Add Mood')
                          ],
                        ),
                        onPressed: () {
                          Navigator.of(_scaffoldKey.currentContext)
                              .push(TransparentRoute(builder: (context) {
                            return MoodSelectionPage(
                              moodList: snapshot.data,
                              saveCallback: saveMood,
                              selectedMood: mMood,
                            );
                          }));
                        });
                  }),
            ],
          ),*/
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ButtonTheme(
                minWidth: (MediaQuery.of(context).size.width / 2) - 30,
                child: RaisedButton(
                  onPressed: () {},
                  child: Text(
                    'Back',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  color: Colors.white,
                ),
              ),
              SizedBox(
                width: 20,
              ),
              ButtonTheme(
                minWidth: (MediaQuery.of(context).size.width / 2) - 30,
                child: RaisedButton(
                  onPressed: save,
                  child: Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconButtonItem buildAddActivityIconButtonItem() {
    return IconButtonItem(
        icon: Column(
          children: [
            Container(
              width: 25,
              height: 50,
              child: Image.asset(
                'assets/activity.png',
                height: 25,
              ),
            ),
            Text('Add Activity')
          ],
        ),
        onPressed: () {
          Navigator.of(_scaffoldKey.currentContext)
              .push(MaterialPageRoute(builder: (context) {
            return ActivitySelectionPage(
              selectedActivityList: activityList,
              onChange: (value) {
                setState(() {
                  activityList = value;
                });
              },
            );
          }));
        });
  }

  IconButtonItem buildAddVideoIconButtonItem(BuildContext context) {
    return IconButtonItem(
        icon: Column(
          children: [
            Container(width: 25, height: 50, child: Icon(Icons.videocam)),
            Text('Add Video'),
          ],
        ),
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return Container(
                  child: Wrap(
                    children: <Widget>[
                      ListTile(
                          leading: Icon(Icons.videocam),
                          title: Text('Video Camera'),
                          onTap: () => {
                                Navigator.of(context).pop(),
                                _onVideoButtonPressedMultiple(
                                    ImageSource.camera,
                                    context: context)
                              }),
                      ListTile(
                        leading: Icon(Icons.video_library),
                        title: Text('Gallery'),
                        onTap: () => {
                          Navigator.of(context).pop(),
                          _onVideoButtonPressedMultiple(ImageSource.gallery,
                              context: context)
                        },
                      ),
                    ],
                  ),
                );
              });
        });
  }

  IconButtonItem buildAddImageIconButtonItem(BuildContext context) {
    return IconButtonItem(
        icon: Column(
          children: [
            Container(width: 25, height: 50, child: Icon(Icons.camera)),
            Text('Add Photo'),
          ],
        ),
        onPressed: () {
          // loadAssets();
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return Container(
                  child: Wrap(
                    children: <Widget>[
                      ListTile(
                          leading: Icon(Icons.camera),
                          title: Text('Camera'),
                          onTap: () => {
                                Navigator.of(context).pop(),
                                _onImageButtonPressedMultiple(
                                    ImageSource.camera,
                                    context: context)
                              }),
                      ListTile(
                        leading: Icon(Icons.photo_library),
                        title: Text('Gallery'),
                        onTap: () => {
                          Navigator.of(context).pop(),
                          _onImageButtonPressedMultiple(ImageSource.gallery,
                              context: context)
                        },
                      ),
                    ],
                  ),
                );
              });
        });
  }

  /*void _onVideoButtonPressed(ip.ImageSource source,
      {BuildContext context}) async {
    final ip.PickedFile file = await _picker.getVideo(
        source: source, maxDuration: const Duration(seconds: 100));
    if (file != null) {
      await _trimmer.loadVideo(videoFile: File(file.path));
      Navigator.of(_scaffoldKey.currentContext)
          .push(MaterialPageRoute(builder: (context) {
        return VideoTrimView(trimmer: _trimmer, saveCallback: saveVideo);
      }));
    }
  }*/

  void saveMood(MMood mood) {
    setState(() {
      mMood = mood;
    });
  }

  /*void _onImageButtonPressed(ip.ImageSource source,
      {BuildContext context}) async {
    Color themeColor = Theme.of(context).primaryColor;
    try {
      final pickedFile = await _picker.getImage(
        source: source,
      );
      File croppedImage = await ImageCropper.cropImage(
        sourcePath: pickedFile.path,
        maxWidth: 1080,
        maxHeight: 1080,
        //aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Preview',
            toolbarColor: themeColor,
            toolbarWidgetColor: Colors.white),
      );

      croppedImage = croppedImage.renameSync(
          '/data/user/0/com.mindframe.mood_manager/cache/' +
              uuid.v1() +
              '.jpg');
      if (croppedImage != null) {
        setState(() {
          imageFile = ParseFile(croppedImage);
        });
        print(imageFile);
      }
    } catch (e) {
      print(e);
    }
  }*/

  Widget iconButton({Widget icon, Function onPressed}) {
    return IconButtonItem(
      icon: icon,
      onPressed: onPressed,
    );
  }

  /*Widget selectedImageWidget() {
    return Container(
        child: Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        width: 150,
        height: 100,
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover,
                image: FileImage(
                  imageFile.file,
                )),
            border: Border.all(width: 1),
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        child: IconButton(
          icon: Column(
            children: [
              Container(
                width: 25,
                height: 50,
                child: Icon(Icons.camera, color: Colors.white),
              ),
              Text(
                'Add Photo',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          onPressed: () {},
        ),
      ),
    ));
  }*/

  /*Widget selectedVideoWidget() {
    return Container(
        child: Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        width: 150,
        height: 100,
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover, image: MemoryImage(thumbnailBytes)),
            border: Border.all(width: 1),
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        child: IconButton(
          icon: Column(
            children: [
              Container(
                width: 25,
                height: 50,
                child: Icon(Icons.videocam, color: Colors.white),
              ),
              Text(
                'Add Video',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          onPressed: () {},
        ),
      ),
    ));
  }*/

  @override
  void initState() {
    super.initState();
    // _picker = sl<ImagePicker>();
    uuid = sl<Uuid>();
  }

  void save() {
    var logDateTime = DateTimeField.combine(date, time);
    final pictureCollectionCode = uuid.v1();
    final videoCollectionCode = uuid.v1();
    final pictureCollection = CollectionParse(
      code: pictureCollectionCode,
      name: pictureCollectionCode,
      mediaType: 'PICTURE',
      module: 'MEMORY',
      mediaCount: imageFileMapByThumbnail.length,
    );
    final videoCollection = CollectionParse(
      code: videoCollectionCode,
      name: videoCollectionCode,
      mediaType: 'VIDEO',
      module: 'MEMORY',
      mediaCount: videoFileMapByThumbnail.length,
    );
    final List<MediaCollection> mediaCollectionList = [
      ...(imageFileMapByThumbnail ?? {}).keys.map((key) {
        return MediaCollection(
          collection: pictureCollection,
          isActive: true,
          media: MediaParse(
              mediaType: "PHOTO",
              file: imageFileMapByThumbnail[key],
              thumbnail: ParseFile(
                File(key),
              )),
        );
      }).toList(),
      ...(videoFileMapByThumbnail ?? {}).keys.map((key) {
        return MediaCollection(
          collection: videoCollection,
          isActive: true,
          media: MediaParse(
              mediaType: "VIDEO",
              file: videoFileMapByThumbnail[key],
              thumbnail: ParseFile(File(key))),
        );
      }).toList()
    ];
    final memory = MemoryParse(
        note: noteController.text,
        logDateTime: logDateTime,
        mMood: mMood,
        mActivityList: activityList,
        collectionList: [pictureCollection, videoCollection]);
    // return;
    widget.saveCallback(memory, mediaCollectionList);
  }

  /*Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    List<ParseFile> selectedImageList = [];
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Example App",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    resultList.forEach((element) async {
      var absolutePath =
          await FlutterAbsolutePath.getAbsolutePath(element.identifier);
      selectedImageList.add(ParseFile(
        File(absolutePath),
      ));
    });
    setState(() {
      images = resultList;
      imageFileList = selectedImageList;
    });
  }*/

  Future<File> cropImage(File image) async {
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: image.path,
      maxWidth: 1080,
      maxHeight: 1080,
      //aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Preview',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white),
    );
    return croppedImage;
  }

  void _onImageButtonPressedMultiple(ImageSource source,
      {BuildContext context}) async {
    final cacheDir = await getTemporaryDirectory();
    try {
      final pickedFileList = await MultiMediaPicker.pickImages(
        source: source,
      );

      if (pickedFileList != null && pickedFileList.isNotEmpty) {
        setState(() {
          for (final pickedFile in pickedFileList) {
            final thumbnailImage = img.copyResize(
                img.decodeImage(pickedFile.readAsBytesSync()),
                width: 200);
            final thumbnailFile =
                File(cacheDir.path + "/" + uuid.v1() + ".jpg");
            thumbnailFile.writeAsBytesSync(img.encodeJpg(thumbnailImage));
            imageFileMapByThumbnail[thumbnailFile.path] = ParseFile(pickedFile);
          }
        });
        Navigator.of(_scaffoldKey.currentContext)
            .push(TransparentRoute(builder: (context) {
          return ImageGridView(
            imagesMap: imageFileMapByThumbnail,
            onChanged: (value) {
              imageFileMapByThumbnail = value;
            },
          );
        }));
      }
    } catch (e) {
      print(e);
    }
  }

  void _onVideoButtonPressedMultiple(ImageSource source,
      {BuildContext context}) async {
    final cacheDir = await getTemporaryDirectory();
    final pickedFile = await MultiMediaPicker.pickVideo(source: source);
    if (pickedFile != null) {
      final thumbnailFile = File(cacheDir.path + "/" + uuid.v1() + ".jpg");

      await VideoThumbnail.thumbnailFile(
        video: pickedFile.path,
        thumbnailPath: thumbnailFile.path,
        imageFormat: ImageFormat.JPEG,
        maxHeight:
            200, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
        quality: 50,
      );
      setState(() {
        videoFileMapByThumbnail[thumbnailFile.path] = ParseFile(pickedFile);
      });
      Navigator.of(_scaffoldKey.currentContext)
          .push(TransparentRoute(builder: (context) {
        return VideoGridView(
          videosMap: videoFileMapByThumbnail,
          onChanged: (value) {
            videoFileMapByThumbnail = value;
          },
        );
      }));
    }
  }
}

class BlurImageGridItem extends StatelessWidget {
  const BlurImageGridItem({
    Key key,
    @required this.context,
    @required this.child,
    @required this.imageList,
  }) : super(key: key);

  final BuildContext context;
  final Widget child;
  final List<ParseFile> imageList;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: 2,
            sigmaY: 2,
          ),
          child: Container(
            padding: EdgeInsets.all(6),
            child: GridView.count(
              childAspectRatio: 1.25,
              crossAxisCount: imageList.length >= 2 ? 2 : 1,
              children: imageList
                  .map((e) => Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.cover, image: FileImage(e.file)))))
                  .toList(),
            ),
          ),
        ),
        Positioned.fill(
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.5),
              BlendMode.darken,
            ),
            child: child,
          ),
        )
      ],
    );
  }
}

class BlurActivityGridItem extends StatelessWidget {
  const BlurActivityGridItem({
    Key key,
    @required this.context,
    @required this.child,
    @required this.activityList,
  }) : super(key: key);

  final BuildContext context;
  final Widget child;
  final List<MActivity> activityList;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: 0,
            sigmaY: 0,
          ),
          child: Container(
            padding: EdgeInsets.all(6),
            child: GridView.count(
              childAspectRatio: 1.25,
              crossAxisCount: 2,
              children: activityList
                  .map((e) => Container(
                          child: new RotationTransition(
                        turns: new AlwaysStoppedAnimation(-45 / 360),
                        child: Center(
                          child: Text(
                            e.activityName,
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      )))
                  .toList(),
            ),
          ),
        ),
        Positioned.fill(
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.5),
              BlendMode.darken,
            ),
            child: child,
          ),
        )
      ],
    );
  }
}

class IconButtonItem extends StatelessWidget {
  final Widget icon;
  final Function onPressed;
  IconButtonItem({
    Key key,
    this.icon,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
          border: Border.all(width: 1),
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      child: IconButton(
        icon: icon,
        onPressed: onPressed,
      ),
    );
  }
}
