import 'dart:io';
import 'package:dartz/dartz.dart' show cast;
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mood_manager/features/metadata/data/datasources/m_mood_remote_data_source.dart';
import 'package:mood_manager/features/metadata/data/datasources/m_activity_remote_data_source.dart';
import 'package:mood_manager/features/common/data/models/collection_parse.dart';
import 'package:mood_manager/features/memory/data/models/memory_parse.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity_type.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_mood.dart';
import 'package:mood_manager/features/common/presentation/widgets/choice_chip_group_selection_page.dart';
import 'package:mood_manager/features/common/presentation/widgets/date_selector.dart';
import 'package:mood_manager/features/common/presentation/widgets/mood_selection_dialog.dart';
import 'package:mood_manager/features/common/presentation/widgets/time_picker.dart';
import 'package:mood_manager/features/common/presentation/widgets/video_trim_view.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/widgets.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import 'package:video_trimmer/video_trimmer.dart';

class MemoryFormPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MemoryFormPageState();
}

class _MemoryFormPageState extends State<MemoryFormPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ImagePicker _picker = sl<ImagePicker>();
  Trimmer _trimmer = sl<Trimmer>();
  DateTime date = DateTime.now();
  TimeOfDay time = TimeOfDay.now();
  ParseFile imageFile;
  ParseFile videoFile;
  List<MActivity> activityList = [];
  final TextEditingController noteController = TextEditingController();
  MMood mMood;
  VideoPlayerController _controller;
  Uuid uuid;
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (imageFile != null) selectedImageWidget(),
              if (imageFile == null)
                getIconButton(
                    Column(
                      children: [
                        Container(
                            width: 25, height: 50, child: Icon(Icons.camera)),
                        Text('Add Photo'),
                      ],
                    ), () {
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
                                        _onImageButtonPressed(
                                            ImageSource.camera,
                                            context: context)
                                      }),
                              ListTile(
                                leading: Icon(Icons.photo_library),
                                title: Text('Gallery'),
                                onTap: () => {
                                  Navigator.of(context).pop(),
                                  _onImageButtonPressed(ImageSource.gallery,
                                      context: context)
                                },
                              ),
                            ],
                          ),
                        );
                      });
                }),
              if (videoFile != null) selectedVideoWidget(),
              if (videoFile == null)
                getIconButton(
                    Column(
                      children: [
                        Container(
                            width: 25, height: 50, child: Icon(Icons.videocam)),
                        Text('Add Video'),
                      ],
                    ), () {
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
                                        _onVideoButtonPressed(
                                            ImageSource.camera,
                                            context: context)
                                      }),
                              ListTile(
                                leading: Icon(Icons.video_library),
                                title: Text('Gallery'),
                                onTap: () => {
                                  Navigator.of(context).pop(),
                                  _onVideoButtonPressed(ImageSource.gallery,
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
              FutureBuilder<List<MActivity>>(
                  initialData: [],
                  future: sl<MActivityRemoteDataSource>()
                      .getMActivityListGroupByType(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data.isEmpty) {
                      return getIconButton(
                          Container(
                              width: 20, height: 20, child: LoadingWidget()),
                          () {});
                    }
                    return getIconButton(
                        Column(
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
                        ), () {
                      Navigator.of(_scaffoldKey.currentContext)
                          .push(MaterialPageRoute(builder: (context) {
                        return ChoiceChipGroupSelectionPage<MActivity>(
                          groupLabel: (group) =>
                              cast<MActivityType>(group).activityTypeName,
                          choiceChipOptions: ChoiceChipGroupSelectionOption
                              .listFrom<MActivity, MActivity>(
                            source: snapshot.data,
                            value: (index, item) => item,
                            label: (index, item) => item.activityName,
                            group: (index, item) => item.mActivityType,
                          ),
                          initialValue: activityList,
                          onChange: (List value) {
                            setState(() {
                              activityList = List<MActivity>.from(value);
                            });
                          },
                        );
                      }));
                    });
                  }),
              FutureBuilder<List<MMood>>(
                  initialData: [],
                  future: sl<MMoodRemoteDataSource>().getMMoodList(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data.isEmpty) {
                      return getIconButton(
                          Container(
                              width: 20, height: 20, child: LoadingWidget()),
                          () {});
                    }
                    return getIconButton(
                        Column(
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
                        ), () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              MoodSelectionDialog(
                                moodList: snapshot.data,
                                saveCallback: saveMood,
                                selectedMood: mMood,
                              ));
                    });
                  }),
            ],
          ),
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
                  onPressed: () {},
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

  void _onVideoButtonPressed(ImageSource source, {BuildContext context}) async {
    final PickedFile file = await _picker.getVideo(
        source: source, maxDuration: const Duration(seconds: 100));
    if (file != null) {
      await _trimmer.loadVideo(videoFile: File(file.path));
      Navigator.of(_scaffoldKey.currentContext)
          .push(MaterialPageRoute(builder: (context) {
        return VideoTrimView(trimmer: _trimmer, saveCallback: saveVideo);
      }));
    }
  }

  void saveVideo(File file) {
    setState(() {
      videoFile = ParseFile(file);
      _controller = VideoPlayerController.file(videoFile.file)
        ..initialize().then((_) {
          setState(() {}); //when your thumbnail will show.
        });
    });
  }

  void saveMood(MMood mood) {
    setState(() {
      mMood = mood;
    });
  }

  void _onImageButtonPressed(ImageSource source, {BuildContext context}) async {
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
      if (croppedImage != null) {
        setState(() {
          imageFile = ParseFile(File(croppedImage.path));
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Widget getIconButton(Widget icon, Function onPressed) {
    return Container(
        child: Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        width: 150,
        height: 100,
        decoration: BoxDecoration(
            border: Border.all(width: 1),
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        child: IconButton(
          icon: icon,
          onPressed: onPressed,
        ),
      ),
    ));
  }

  Widget selectedImageWidget() {
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
  }

  Widget selectedVideoWidget() {
    return Container(
        child: Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        width: 150,
        height: 100,
        decoration: BoxDecoration(
            border: Border.all(width: 1),
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        child: Stack(
          children: [
            VideoPlayer(
              _controller,
            ),
            Center(
              child: Column(
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
            ),
          ],
        ),
      ),
    ));
  }

  @override
  void initState() {
    super.initState();
    _picker = sl<ImagePicker>();
    uuid = sl<Uuid>();
  }

  save() {
    var logDateTime = DateTimeField.combine(date, time);
    final pictureCollectionCode = uuid.v1();
    final videoCollectionCode = uuid.v1();
    final memory = MemoryParse(
        note: noteController.text,
        logDateTime: logDateTime,
        mMood: mMood,
        mActivityList: activityList,
        collectionList: [
          CollectionParse(
            code: pictureCollectionCode,
            name: '',
            mediaType: 'PICTURE',
            module: 'MEMORY',
          ),
          CollectionParse(
            code: videoCollectionCode,
            name: '',
            mediaType: 'VIDEO',
            module: 'MEMORY',
          )
        ]);
  }
}
