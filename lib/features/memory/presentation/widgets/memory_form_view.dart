import 'dart:io';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mood_manager/core/constants/app_constants.dart';
import 'package:mood_manager/core/util/color_util.dart';
import 'package:mood_manager/core/util/date_util.dart';
import 'package:mood_manager/features/common/data/datasources/common_remote_data_source.dart';
import 'package:mood_manager/features/common/data/datasources/media_file_service.dart';
import 'package:mood_manager/features/common/data/models/media_collection_mapping_parse.dart';
import 'package:mood_manager/features/common/data/models/media_parse.dart';
import 'package:mood_manager/features/common/domain/entities/base_states.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection_mapping.dart';
import 'package:mood_manager/features/common/presentation/pages/activity_selection_page.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:mood_manager/features/memory/presentation/pages/media_grid_view.dart';
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
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:uuid/uuid.dart';
import 'package:mood_manager/home.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class MemoryFormView extends StatefulWidget {
  final Function saveCallback;
  final Memory memory;
  Task task;
  DateTime date;

  MemoryFormView({
    Key key,
    this.saveCallback,
    this.date,
    this.memory,
    this.task,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MemoryFormViewState(memory: memory);
}

class _MemoryFormViewState extends State<MemoryFormView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TimeOfDay time = TimeOfDay.now();
  List<MActivity> activityList = [];
  final FocusNode titleFocusNode = FocusNode();
  final FocusNode noteFocusNode = FocusNode();
  final TextEditingController noteTitleController = TextEditingController();
  final TextEditingController noteTextController = TextEditingController();
  MMood mMood;
  Uuid uuid;
  List<MediaCollectionMapping> imageMediaCollectionList = [];
  List<MediaCollectionMapping> videoMediaCollectionList = [];
  final commonRemoteDataSource = sl<CommonRemoteDataSource>();
  final MediaFileService mediaFileService = sl<MediaFileService>();
  final Directory tempDirectory = sl<Directory>('tempDirectory');

  _MemoryFormViewState({Memory memory}) {
    if (memory != null) {
      time = TimeOfDay.fromDateTime(memory.logDateTime);
      activityList = memory.mActivityList;
      noteTitleController.text = memory.title;
      noteTextController.text = memory.note;
      mMood = memory.mMood;
      commonRemoteDataSource.isConnected().then((value) {
        if (value) {
          final mediaCollectionFutureList =
              commonRemoteDataSource.getMediaCollectionMappingByCollectionList(
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
      });
    }
  }

  @override
  void initState() {
    super.initState();
    uuid = sl<Uuid>();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'FormView',
      child: Scaffold(
        key: _scaffoldKey,
        body: AnimationLimiter(
          child: ListView(
              physics: BouncingScrollPhysics(),
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder: (widget) => SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(
                    child: widget,
                  ),
                ),
                children: [
                  if (widget.task != null)
                    Container(
                      height: 40,
                      child: Center(
                        child: Text(
                          DateFormat(AppConstants.HEADER_DATE_FORMAT)
                              .format(widget.date),
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (widget.task == null)
                    DateSelector(
                      enabled: widget.task == null,
                      initialDate: widget.date,
                      selectDate: (DateTime date) {
                        setState(() {
                          widget.date = date;
                        });
                      },
                      endDate: DateTime.now(),
                    ),
                  TimePickerButton(
                    enabled: widget.task == null,
                    selectedTime: time,
                    selectTime: (time) {
                      setState(() {
                        if (DateUtil.combine(widget.date, time)
                            .isAfter(DateTime.now())) {
                          this.time = TimeOfDay.fromDateTime(DateTime.now());
                        } else {
                          this.time = time;
                        }
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
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                        ),
                        child: Column(
                          children: [
                            TextField(
                              maxLength: 100,
                              maxLengthEnforcement:
                                  MaxLengthEnforcement.enforced,
                              style: TextStyle(fontSize: 20),
                              controller: noteTitleController,
                              minLines: 1,
                              maxLines: 1,
                              autocorrect: false,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Title',
                                filled: true,
                                fillColor: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.0),
                              ),
                              focusNode: titleFocusNode,
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
                                fillColor: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.0),
                              ),
                              focusNode: noteFocusNode,
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
                        crossAxisCount:
                            orientation == Orientation.portrait ? 2 : 4,
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
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).primaryColor,
                          onPrimary: Colors.white),
                      onPressed: save,
                      child: Text(
                        '${(widget.memory?.id ?? '').isNotEmpty ? 'Save' : 'Add'} to Memories',
                        //style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  Widget get activity {
    if (activityList.isNotEmpty)
      return BlurActivityGridItem(
        context: context,
        child: buildAddActivityIconButtonItem(),
        activityList: activityList,
      );
    return buildAddActivityIconButtonItem();
  }

  Widget get mood {
    return FutureBuilder<List<MMood>>(
        initialData: [],
        future: sl<MMoodRemoteDataSource>().getMMoodList(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data.isEmpty) {
            return iconButton(
                icon: Container(width: 20, height: 20, child: LoadingWidget()),
                onPressed: () {});
          }
          return BlurMoodGridItem(
            context: context,
            child: buildAddMoodIconButtonItem(snapshot),
            moodList: snapshot.data,
            mood: mMood,
          );
        });
  }

  Widget get image {
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

  Widget get video {
    if (videoMediaCollectionList.isNotEmpty)
      return BlurImageGridItem(
          context: context,
          child: buildAddVideoIconButtonItem(context),
          imageList: videoMediaCollectionList
              .where((element) => element.isActive)
              .map((e) => e.media.thumbnail)
              .toList(),
          viewCallback: () {
            navigateToVideoGrid(null);
          });
    return buildAddVideoIconButtonItem(context);
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
          hideKeyboard();
          Navigator.of(appNavigatorContext(context))
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
                  mMood == null ? Icons.add : Icons.edit,
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
          hideKeyboard();
          Navigator.of(appNavigatorContext(context))
              .push(TransparentRoute(builder: (context) {
            return MoodSelectionPage(
              moodList: snapshot.data,
              saveCallback: setMood,
              selectedMood: mMood,
            );
          }));
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
          hideKeyboard();
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return Container(
                  child: Wrap(
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.photo_library),
                        title: Text('Album'),
                        onTap: () async {
                          Navigator.of(appNavigatorContext(context)).pop();
                          final pickedFileList =
                              await mediaFileService.pickFilesFromAlbum(
                                  context: context, mediaType: 'PHOTO');
                          if ((pickedFileList ?? []).isNotEmpty) {
                            handleFuture<void>(
                                () => selectImages(pickedFileList));
                          }
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.photo_library_outlined),
                        title: Text('Gallery'),
                        onTap: () async {
                          Navigator.of(appNavigatorContext(context)).pop();
                          List<File> pickedFileList = await mediaFileService
                              .pickFiles(type: FileType.image);
                          if ((pickedFileList ?? []).isNotEmpty) {
                            handleFuture<void>(
                                () => selectImages(pickedFileList));
                          }
                        },
                      ),
                      ListTile(
                          leading: Icon(Icons.camera),
                          title: Text('Camera'),
                          onTap: () async {
                            final pickedFile =
                                await mediaFileService.pickFileFromCamera(
                                    context: context, mediaType: 'PHOTO');
                            if (pickedFile != null) {
                              handleFuture<void>(
                                  () => selectImages([pickedFile]));
                            }
                          }),
                    ],
                  ),
                );
              });
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
          hideKeyboard();
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return Container(
                  child: Wrap(
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.video_collection),
                        title: Text('Album'),
                        onTap: () async {
                          Navigator.of(appNavigatorContext(context)).pop();
                          final pickedFileList =
                              await mediaFileService.pickFilesFromAlbum(
                                  context: context, mediaType: 'VIDEO');
                          if ((pickedFileList ?? []).isNotEmpty) {
                            selectVideos(pickedFileList);
                          }
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.video_collection_outlined),
                        title: Text('Gallery'),
                        onTap: () async {
                          Navigator.of(appNavigatorContext(context)).pop();
                          final pickedFileList = await mediaFileService
                              .pickFiles(type: FileType.video);
                          if ((pickedFileList ?? []).isNotEmpty) {
                            selectVideos(pickedFileList);
                          }
                        },
                      ),
                      ListTile(
                          leading: Icon(Icons.videocam),
                          title: Text('Video Camera'),
                          onTap: () async {
                            final pickedFile =
                                await mediaFileService.pickFileFromCamera(
                                    mediaType: 'VIDEO', context: context);
                            if (pickedFile != null) {
                              selectVideos([pickedFile]);
                            }
                          }),
                    ],
                  ),
                );
              });
        });
  }

  void setMood(MMood mood) {
    setState(() {
      mMood = mood;
    });
  }

  Widget iconButton({Widget icon, Function onPressed}) {
    return IconButtonItem(
      icon: icon,
      onPressed: onPressed,
    );
  }

  Future<void> save() async {
    hideKeyboard();
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
    if (memory.title == null || memory.title.trim().isEmpty) {
      Fluttertoast.showToast(
          gravity: ToastGravity.TOP,
          msg: 'Title is mandatory',
          backgroundColor: Colors.red);
    } else {
      widget.saveCallback(
          memory, [...imageMediaCollectionList, ...videoMediaCollectionList]);
    }
  }

  Future<void> selectImages(List<File> fileList) async {
    var photoCollection;
    if (fileList != null && fileList.isNotEmpty) {
      for (final pickedFile in fileList) {
        var mediaParse = MediaParse(
          file: ParseFile(pickedFile),
          mediaType: 'PHOTO',
        );
        await mediaParse.setThumbnail(tempDirectory.path, uuid.v1());
        await mediaParse.setDominantColor();
        if ((widget.memory?.mediaCollectionList ?? [])
            .any((element) => element.mediaType == 'PHOTO')) {
          photoCollection = widget.memory.mediaCollectionList
              .firstWhere((element) => element.mediaType == 'PHOTO');
        } else if (imageMediaCollectionList.isNotEmpty) {
          photoCollection = imageMediaCollectionList.first.collection;
        } else {
          photoCollection = MediaCollectionParse(
            code: uuid.v1(),
            mediaType: 'PHOTO',
            module: 'MEMORY',
            name: uuid.v1(),
            user: (await ParseUser.currentUser()) as ParseUser,
          );
        }
        imageMediaCollectionList.add(
          MediaCollectionMappingParse(
            collection: photoCollection,
            media: mediaParse,
          ),
        );
      }
      setState(() {});
      navigateToImageGrid();
    }
  }

  Future<void> selectVideos(List<File> fileList) async {
    var videoCollection;
    if (fileList != null && fileList.isNotEmpty) {
      for (final pickedFile in fileList) {
        var mediaParse = MediaParse(
          file: ParseFile(pickedFile),
          mediaType: 'VIDEO',
        );
        await mediaParse.setThumbnail(tempDirectory.path, uuid.v1());
        await mediaParse.setDominantColor();
        if ((widget.memory?.mediaCollectionList ?? [])
            .any((element) => element.mediaType == 'PHOTO')) {
          videoCollection = widget.memory.mediaCollectionList
              .firstWhere((element) => element.mediaType == 'PHOTO');
        } else if (videoMediaCollectionList.isNotEmpty) {
          videoCollection = videoMediaCollectionList.first.collection;
        } else {
          videoCollection = MediaCollectionParse(
            code: uuid.v1(),
            mediaType: 'VIDEO',
            module: 'MEMORY',
            name: uuid.v1(),
            user: (await ParseUser.currentUser()) as ParseUser,
          );
        }
        videoMediaCollectionList.add(
          MediaCollectionMappingParse(
            collection: videoCollection,
            media: mediaParse,
          ),
        );
      }
      setState(() {});
      navigateToVideoGrid(null);
    }
  }

  navigateToImageGrid() {
    Navigator.of(appNavigatorContext(context))
        .push(TransparentRoute(builder: (context) {
      return MediaGridView(
          onChanged: (mediaCollectionList) {
            if (mediaCollectionList != null) {
              var list = List<MediaCollectionMapping>.from(mediaCollectionList);
              setState(() {
                final removedImageMediaCollectionList =
                    imageMediaCollectionList.where((element) {
                  return !list.contains(element);
                }).toList();
                removedImageMediaCollectionList.forEach((element) {
                  element.isActive = false;
                });
                imageMediaCollectionList = [
                  ...list,
                  ...removedImageMediaCollectionList
                ];
              });
            }
          },
          mediaType: 'PHOTO',
          mediaCollectionList: List<MediaCollectionMapping>.from(
              imageMediaCollectionList.where((element) => element.isActive)));
    }));
  }

  navigateToVideoGrid(MediaCollectionMapping mediaCollectionMapping) {
    Navigator.of(appNavigatorContext(context))
        .push(TransparentRoute(builder: (context) {
      return MediaGridView(
        toBeAddedMediaCollectionMapping: mediaCollectionMapping,
        mediaType: 'VIDEO',
        mediaCollectionList: videoMediaCollectionList
            .where((element) => element.isActive)
            .toList(),
        onChanged: (mediaCollectionList) {
          if (mediaCollectionList != null) {
            var list = List<MediaCollectionMapping>.from(mediaCollectionList);
            setState(() {
              final removedVideoMediaCollectionList = videoMediaCollectionList
                  .where((element) => !list.contains(element))
                  .toList();
              removedVideoMediaCollectionList.forEach((element) {
                element.isActive = false;
              });
              videoMediaCollectionList = [
                ...list,
                ...(removedVideoMediaCollectionList
                    .where((element) => element.id != null)
                    .toList())
              ];
            });
          }
        },
      );
    }));
  }

  hideKeyboard() {
    titleFocusNode.unfocus();
    noteFocusNode.unfocus();
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
                initialValue: mood == null
                    ? null
                    : moodList.firstWhere((element) =>
                        [element, ...element.mMoodList].contains(mood)),
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
