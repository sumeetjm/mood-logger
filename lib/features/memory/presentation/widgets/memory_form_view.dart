import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mood_manager/core/util/color_util.dart';
import 'package:mood_manager/core/util/date_util.dart';
import 'package:mood_manager/features/common/data/datasources/common_remote_data_source.dart';
import 'package:mood_manager/features/common/data/models/media_collection_mapping_parse.dart';
import 'package:mood_manager/features/common/data/models/media_parse.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection_mapping.dart';
import 'package:mood_manager/features/common/presentation/pages/activity_selection_page.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:mood_manager/features/memory/presentation/pages/image_grid_view.dart';
import 'package:mood_manager/features/memory/presentation/pages/video_grid_view.dart';
import 'package:mood_manager/features/memory/presentation/widgets/transparent_page_route.dart';
import 'package:mood_manager/features/metadata/data/datasources/m_mood_remote_data_source.dart';
import 'package:mood_manager/features/common/data/models/media_collection_parse.dart';
import 'package:mood_manager/features/memory/data/models/memory_parse.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_mood.dart';
import 'package:mood_manager/features/common/presentation/widgets/date_selector.dart';
import 'package:mood_manager/features/common/presentation/widgets/mood_selection_dialog.dart';
import 'package:mood_manager/features/common/presentation/widgets/time_picker_button.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/radio_selection.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/widgets.dart';
import 'package:mood_manager/features/reminder/domain/entities/task.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:multi_media_picker/multi_media_picker.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:palette_generator/palette_generator.dart';

// ignore: must_be_immutable
class MemoryFormView extends StatefulWidget {
  final Function saveCallback;
  final Memory memory;
  DateTime date;

  MemoryFormView({Key key, this.saveCallback, this.date, this.memory})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _MemoryFormViewState(memory: memory);
}

class _MemoryFormViewState extends State<MemoryFormView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TimeOfDay time = TimeOfDay.now();
  List<MActivity> activityList = [];
  final TextEditingController noteTitleController = TextEditingController();
  final TextEditingController noteTextController = TextEditingController();
  MMood mMood;
  Uuid uuid;
  List<MediaCollectionMapping> imageMediaCollectionList = [];
  List<MediaCollectionMapping> videoMediaCollectionList = [];

  _MemoryFormViewState({Memory memory}) {
    if (memory != null) {
      time = TimeOfDay.fromDateTime(memory.logDateTime);
      activityList = memory.mActivityList;
      noteTitleController.text = memory.title;
      noteTextController.text = memory.note;
      mMood = memory.mMood;
      final mediaCollectionFutureList = sl<CommonRemoteDataSource>()
          .getMediaCollectionMappingByCollectionList(
              memory.mediaCollectionList ?? []);
      mediaCollectionFutureList.then((mediaCollectionList) {
        imageMediaCollectionList = mediaCollectionList
            .where((element) => element.media.mediaType == "PHOTO")
            .toList();
        videoMediaCollectionList = mediaCollectionList
            .where((element) => element.media.mediaType == "VIDEO")
            .toList();
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'FormView',
      child: Scaffold(
        key: _scaffoldKey,
        body: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            DateSelector(
              initialDate: widget.date,
              selectDate: (DateTime date) {
                setState(() {
                  widget.date = date;
                });
              },
              endDate: DateTime.now(),
            ),
            TimePickerButton(
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
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        style: TextStyle(fontSize: 20),
                        controller: noteTitleController,
                        minLines: 1,
                        maxLines: 1,
                        autocorrect: false,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Title',
                          filled: true,
                          fillColor:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          /*enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),*/
                        ),
                      ),
                      TextField(
                        controller: noteTextController,
                        minLines: 6,
                        maxLines: 15,
                        autocorrect: false,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Write your story here',
                          filled: true,
                          fillColor:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          /*enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),*/
                        ),
                      ),
                    ],
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
                    activity,
                    mood,
                    image,
                    video,
                  ],
                ),
              );
            }),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 8, 15, 0),
              child: RaisedButton(
                onPressed: save,
                child: Text(
                  '${(widget.memory?.id ?? '').isNotEmpty ? 'Save' : 'Add'} to Memories',
                  style: TextStyle(color: Colors.white),
                ),
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconButtonItem buildAddMoodIconButtonItem(
      AsyncSnapshot<List<MMood>> snapshot) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  mMood != null ? Icons.edit : Icons.add,
                  size: 18,
                ),
                SizedBox(
                  width: 8,
                ),
                Text('Mood'),
              ],
            )
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  (activityList ?? []).isNotEmpty ? Icons.edit : Icons.add,
                  size: 18,
                ),
                SizedBox(
                  width: 8,
                ),
                Text('Activity'),
              ],
            )
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  size: 18,
                ),
                SizedBox(
                  width: 8,
                ),
                Text('Video'),
              ],
            )
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  size: 18,
                ),
                SizedBox(
                  width: 8,
                ),
                Text('Photo'),
              ],
            )
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

  Future<Color> getImagePalette(ImageProvider imageProvider) async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(imageProvider);
    return paletteGenerator.dominantColor.color;
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

  @override
  void initState() {
    super.initState();
    // _picker = sl<ImagePicker>();
    uuid = sl<Uuid>();
  }

  void save() async {
    var logDateTime = DateUtil.combine(widget.date, time);
    final memory = MemoryParse(
      id: widget.memory?.id,
      title: noteTitleController.text,
      note: noteTextController.text,
      logDateTime: logDateTime,
      mMood: mMood,
      mActivityList: activityList,
      collectionList: [...imageMediaCollectionList, ...videoMediaCollectionList]
          .toSet()
          .map((e) => e.collection)
          .toList(),
      user: await ParseUser.currentUser() as ParseUser,
    );
    // return;
    widget.saveCallback(
        memory, [...imageMediaCollectionList, ...videoMediaCollectionList]);
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
        for (final pickedFile in pickedFileList) {
          final thumbnailImage = img.copyResize(
              img.decodeImage(pickedFile.readAsBytesSync()),
              width: 200);
          final thumbnailFile = File(cacheDir.path + "/" + uuid.v1() + ".jpg");
          thumbnailFile.writeAsBytesSync(img.encodeJpg(thumbnailImage));
          var photoCollection;
          if (widget.memory?.mediaCollectionList != null &&
              (widget.memory?.mediaCollectionList ?? [])
                  .any((element) => element.mediaType == 'PHOTO')) {
            photoCollection = widget.memory.mediaCollectionList
                .firstWhere((element) => element.mediaType == 'PHOTO')
                .incrementMediaCount();
          } else {
            photoCollection = MediaCollectionParse(
              code: uuid.v1(),
              mediaCount: 1,
              mediaType: 'PHOTO',
              module: 'MEMORY',
              name: uuid.v1(),
              user: (await ParseUser.currentUser()) as ParseUser,
            );
          }
          imageMediaCollectionList.add(
            MediaCollectionMappingParse(
              collection: photoCollection,
              media: MediaParse(
                file: ParseFile(pickedFile),
                thumbnail: ParseFile(thumbnailFile),
                mediaType: 'PHOTO',
              ),
            ),
          );
          /*imageFileMapByThumbnail[ParseFile(thumbnailFile)] =
                ParseFile(pickedFile);*/
        }
        setState(() {});
        navigateToImageGrid();
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
      var videoCollection;

      if (widget.memory?.mediaCollectionList != null &&
          (widget.memory?.mediaCollectionList ?? [])
              .any((element) => element.mediaType == 'VIDEO')) {
        videoCollection = widget.memory.mediaCollectionList
            .firstWhere((element) => element.mediaType == 'VIDEO')
            .incrementMediaCount();
      } else {
        videoCollection = MediaCollectionParse(
          code: uuid.v1(),
          mediaCount: 1,
          mediaType: 'VIDEO',
          module: 'MEMORY',
          name: uuid.v1(),
          user: (await ParseUser.currentUser()) as ParseUser,
        );
      }

      videoMediaCollectionList.add(
        MediaCollectionMappingParse(
          collection: videoCollection,
          media: MediaParse(
            file: ParseFile(pickedFile),
            thumbnail: ParseFile(thumbnailFile),
            mediaType: 'VIDEO',
          ),
        ),
      );
      setState(() {});
      navigateToVideoGrid();
    }
  }

  get image {
    if (imageMediaCollectionList.where((e) => e.isActive).isNotEmpty)
      return BlurImageGridItem(
          context: context,
          child: buildAddImageIconButtonItem(context),
          imageList: imageMediaCollectionList
              .where((e) => e.isActive)
              .map((e) => e.media.thumbnail)
              .toList(),
          viewCallback: navigateToImageGrid);
    return buildAddImageIconButtonItem(context);
  }

  navigateToImageGrid() async {
    final mediaCollectionList = (await Navigator.of(_scaffoldKey.currentContext)
        .push(TransparentRoute(builder: (context) {
      return ImageGridView(
          imageMediaCollectionList: imageMediaCollectionList
              .where((element) => element.isActive)
              .toList());
    })) as List<MediaCollectionMapping>);
    if (mediaCollectionList != null) {
      setState(() {
        final removedImageMediaCollectionList = imageMediaCollectionList
            .where((element) => !mediaCollectionList.contains(element))
            .toList();
        removedImageMediaCollectionList.forEach((element) {
          element.isActive = false;
        });
        imageMediaCollectionList = [
          ...mediaCollectionList,
          ...removedImageMediaCollectionList
        ];
      });
    }
  }

  get video {
    if (videoMediaCollectionList.isNotEmpty)
      return BlurImageGridItem(
          context: context,
          child: buildAddVideoIconButtonItem(context),
          imageList:
              videoMediaCollectionList.map((e) => e.media.thumbnail).toList(),
          viewCallback: navigateToVideoGrid);
    return buildAddVideoIconButtonItem(context);
  }

  navigateToVideoGrid() async {
    var mediaCollectionList = (await Navigator.of(_scaffoldKey.currentContext)
            .push(TransparentRoute(builder: (context) {
          return VideoGridView(
              videoMediaCollectionList: videoMediaCollectionList
                  .where((element) => element.isActive)
                  .toList());
        })) as List<MediaCollectionMapping>) ??
        [];
    setState(() {
      final removedVideoMediaCollectionList = videoMediaCollectionList
          .where((element) => !mediaCollectionList.contains(element))
          .toList();
      removedVideoMediaCollectionList.forEach((element) {
        element.isActive = false;
      });
      videoMediaCollectionList = [
        ...mediaCollectionList,
        ...removedVideoMediaCollectionList
      ];
    });
  }

  get activity {
    if (activityList.isNotEmpty)
      return BlurActivityGridItem(
        context: context,
        child: buildAddActivityIconButtonItem(),
        activityList: activityList,
      );
    return buildAddActivityIconButtonItem();
  }

  get mood {
    return FutureBuilder<List<MMood>>(
        initialData: [],
        future: sl<MMoodRemoteDataSource>().getMMoodList(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data.isEmpty) {
            return iconButton(
                icon: Container(width: 20, height: 20, child: LoadingWidget()),
                onPressed: () {});
          }
          if (mMood != null) {
            return BlurMoodGridItem(
              context: context,
              child: buildAddMoodIconButtonItem(snapshot),
              moodList: snapshot.data,
              mood: mMood,
            );
          }
          return buildAddMoodIconButtonItem(snapshot);
        });
  }
}

class BlurImageGridItem extends StatelessWidget {
  const BlurImageGridItem({
    Key key,
    @required this.context,
    @required this.child,
    @required this.imageList,
    @required this.viewCallback,
  }) : super(key: key);

  final BuildContext context;
  final Widget child;
  final List<ParseFile> imageList;
  final Function viewCallback;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: 0,
            sigmaY: 0,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: GridView.count(
              childAspectRatio:
                  imageList.length >= 1 && imageList.length < 4 ? 5 / 8 : 5 / 4,
              crossAxisCount: imageList.length >= 2 ? 2 : 1,
              children: imageList
                  .take(4)
                  .map((e) => Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: e.file != null
                                  ? FileImage(e.file)
                                  : NetworkImage(e.url)))))
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
        ),
        Positioned(
          child: GestureDetector(
            child: Icon(
              MdiIcons.viewGridPlusOutline,
              size: 20,
              color: Colors.black.withOpacity(0.5),
            ),
            onTap: viewCallback,
          ),
          right: 1,
          top: 1,
        ),
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
                          style: TextStyle(
                            fontSize: 15,
                            color: ColorUtil.random,
                          ),
                        )),
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

class BlurMoodGridItem extends StatelessWidget {
  const BlurMoodGridItem({
    Key key,
    @required this.context,
    @required this.child,
    @required this.mood,
    @required this.moodList,
  }) : super(key: key);

  final BuildContext context;
  final Widget child;
  final MMood mood;
  final List<MMood> moodList;

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
            child: Center(
              child: RadioSelection(
                moodList: moodList,
                initialValue: mood,
                initialSubValue: mood,
                onChange: null,
                parentCircleColor: Colors.blueGrey[50],
                parentCircleRadius: 55,
                showLabel: false,
                //showClear: true,
              ),
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
