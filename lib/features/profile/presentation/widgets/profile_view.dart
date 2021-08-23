import 'dart:ui';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:image_cropper/image_cropper.dart' as ic;
import 'package:file_picker/file_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mood_manager/core/constants/app_constants.dart';
import 'package:mood_manager/features/common/data/datasources/media_file_service.dart';
import 'package:mood_manager/features/common/data/models/media_collection_mapping_parse.dart';
import 'package:mood_manager/features/common/data/models/media_collection_parse.dart';
import 'package:mood_manager/features/common/data/models/media_parse.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection_mapping.dart';
import 'package:mood_manager/features/common/presentation/widgets/empty_widget.dart';
import 'package:mood_manager/features/profile/data/models/user_profile_parse.dart';
import 'package:mood_manager/features/metadata/domain/entities/gender.dart';
import 'package:mood_manager/features/profile/domain/entities/user_profile.dart';
import 'package:mood_manager/features/common/presentation/widgets/check_box_list_field.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:intl/intl.dart';
import 'package:tinycolor/tinycolor.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:uuid/uuid.dart';

class ProfileView extends StatefulWidget {
  final ValueChanged<UserProfile> saveCallback;
  final Function resetCallback;
  final ValueChanged<MediaCollectionMapping> profilePictureChangeCallback;
  final Function onPictureTapCallback;
  final ValueChanged<String> linkWithSocialCallback;
  final Map<String, Future<int>> countMap;
  final UserProfile value;
  final String uniquekey;
  ProfileView(
      {Key key,
      this.uniquekey,
      this.saveCallback,
      this.resetCallback,
      this.profilePictureChangeCallback,
      this.onPictureTapCallback,
      this.linkWithSocialCallback,
      this.countMap,
      this.value})
      : super(key: key);

  @override
  _ProfileViewState createState() => _ProfileViewState(value);
}

class _ProfileViewState extends State<ProfileView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _focusAbout = FocusNode();
  final FocusNode _focusEmail = new FocusNode();
  final FocusNode _focusName = new FocusNode();
  final FocusNode _focusDateOfBirth = new FocusNode();
  final FocusNode _focusProfession = new FocusNode();
  final Uuid uuid = sl<Uuid>();
  String key;
  UserProfile profileValue;
  MediaFileService mediaFileService = sl<MediaFileService>();
  Directory tempDirectory = sl<Directory>('tempDirectory');

  @override
  void initState() {
    super.initState();
    key = uuid.v1();
  }

  _ProfileViewState(UserProfile userProfile) {
    setProfileValue(userProfile);
  }

  setProfileValue(UserProfile userProfile) {
    profileValue = UserProfile(
        firstName: userProfile.firstName,
        lastName: userProfile.lastName,
        about: userProfile.about,
        dateOfBirth: userProfile.dateOfBirth,
        profession: userProfile.profession,
        profilePicture: userProfile.profilePicture,
        profilePictureCollection: userProfile.profilePictureCollection,
        gender: userProfile.gender,
        interestedIn: userProfile.interestedIn,
        archiveMemoryCollection: userProfile.archiveMemoryCollection,
        id: userProfile.id,
        isActive: userProfile.isActive,
        user: userProfile.user);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          actions: [
            PopupMenuButton(
              onSelected: (valueFn) {
                valueFn.call();
              },
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    value: () {
                      profileValue.profilePicture =
                          AppConstants.DEFAULT_PROFILE_MEDIA;
                      widget.profilePictureChangeCallback(null);
                    },
                    child: Text('Remove profile picture'),
                  )
                ];
              },
            )
          ],
          expandedHeight: 350.0,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            title: Text(
              profileValue.name,
              style: TextStyle(fontSize: 16),
            ),
            background: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: profileValue.profilePicture?.imageProvider ??
                        CachedNetworkImageProvider(
                            AppConstants.DEFAULT_PROFILE_PIC),
                    fit: BoxFit.cover,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    width: double.infinity,
                    height: 350.0,
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Stack(
                            children: [
                              Container(
                                width: 130,
                                height: 130,
                              ),
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 65,
                                child: GestureDetector(
                                  onTap: widget.onPictureTapCallback,
                                  child: Hero(
                                    tag: profileValue?.profilePicture?.tag() ??
                                        uuid.v1(),
                                    child: CircleAvatar(
                                      backgroundImage: profileValue
                                              .profilePicture?.imageProvider ??
                                          CachedNetworkImageProvider(
                                              AppConstants.DEFAULT_PROFILE_PIC),
                                      radius: 60.0,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  backgroundColor:
                                      TinyColor(Theme.of(context).accentColor)
                                          .lighten(20)
                                          .color,
                                  radius: 20,
                                  child: IconButton(
                                      icon: Icon(
                                        Icons.camera_alt,
                                        color: Theme.of(context).primaryColor,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        showModalBottomSheet(
                                            context: context,
                                            builder: (context) {
                                              return Container(
                                                child: Wrap(
                                                  children: <Widget>[
                                                    ListTile(
                                                      leading: Icon(
                                                          Icons.photo_library),
                                                      title: Text('Album'),
                                                      onTap: () async {
                                                        Navigator.of(context)
                                                            .pop();
                                                        final pickedFileList =
                                                            await mediaFileService
                                                                .pickFilesFromAlbum(
                                                                    context:
                                                                        context,
                                                                    mediaType:
                                                                        'PHOTO');
                                                        if ((pickedFileList ??
                                                                [])
                                                            .isNotEmpty) {
                                                          selectImage(
                                                              profileValue,
                                                              pickedFileList
                                                                  .first);
                                                        }
                                                      },
                                                    ),
                                                    ListTile(
                                                      leading: Icon(Icons
                                                          .photo_library_outlined),
                                                      title: Text('Gallery'),
                                                      onTap: () async {
                                                        Navigator.of(context)
                                                            .pop();
                                                        final pickedFileList =
                                                            await mediaFileService
                                                                .pickFiles(
                                                                    type: FileType
                                                                        .image);
                                                        if ((pickedFileList ??
                                                                [])
                                                            .isNotEmpty) {
                                                          selectImage(
                                                              profileValue,
                                                              pickedFileList
                                                                  .first);
                                                        }
                                                      },
                                                    ),
                                                    ListTile(
                                                        leading:
                                                            Icon(Icons.camera),
                                                        title: Text('Camera'),
                                                        onTap: () async {
                                                          Navigator.of(context)
                                                              .pop();
                                                          final pickedFile =
                                                              await mediaFileService
                                                                  .pickFileFromCamera(
                                                                      context:
                                                                          context,
                                                                      mediaType:
                                                                          'PHOTO');
                                                          if (pickedFile !=
                                                              null) {
                                                            selectImage(
                                                                profileValue,
                                                                pickedFile);
                                                          }
                                                        }),
                                                  ],
                                                ),
                                              );
                                            });
                                      }),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 5.0),
                            clipBehavior: Clip.antiAlias,
                            color: TinyColor(Theme.of(context).accentColor)
                                .lighten(25)
                                .color,
                            elevation: 5.0,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 22.0),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          'Tasks',
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5.0,
                                        ),
                                        FutureBuilder<int>(
                                            future: widget.countMap['tasks'],
                                            builder: (context, snapshot) {
                                              final count = snapshot.hasData
                                                  ? snapshot.data
                                                  : 0;
                                              return Text(
                                                count.toString(),
                                                style: TextStyle(
                                                  fontSize: 18.0,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                              );
                                            })
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          'Memories',
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5.0,
                                        ),
                                        FutureBuilder<int>(
                                            future: widget.countMap['memories'],
                                            builder: (context, snapshot) {
                                              final count = snapshot.hasData
                                                  ? snapshot.data
                                                  : 0;
                                              return Text(
                                                count.toString(),
                                                style: TextStyle(
                                                  fontSize: 18.0,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                              );
                                            })
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          'Media',
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5.0,
                                        ),
                                        FutureBuilder<int>(
                                            future: widget.countMap['media'],
                                            builder: (context, snapshot) {
                                              final count = snapshot.hasData
                                                  ? snapshot.data
                                                  : 0;
                                              return Text(
                                                count.toString(),
                                                style: TextStyle(
                                                  fontSize: 18.0,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                              );
                                            })
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
          ),
        ),
        SliverFillRemaining(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Form(
              key: _formKey,
              child: AnimationLimiter(
                child: ListView(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 375),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        horizontalOffset: 50.0,
                        child: FadeInAnimation(
                          child: widget,
                        ),
                      ),
                      children: [
                        TextFormField(
                          focusNode: _focusName,
                          initialValue: profileValue.name,
                          autovalidateMode: AutovalidateMode.always,
                          validator: (value) {
                            if (value != null &&
                                value.isNotEmpty &&
                                !RegExp(AppConstants.NO_SPECIAL_CHARACTER_REGEX)
                                    .hasMatch(value)) {
                              return 'Enter a valid name';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
                          style: TextStyle(color: Colors.black, fontSize: 16),
                          onChanged: (value) {
                            profileValue.name = value;
                          },
                          decoration:
                              getInputDecoration(context, 'Name', _focusName),
                        ),
                        TextFormField(
                          focusNode: _focusAbout,
                          initialValue: profileValue.about,
                          autovalidateMode: AutovalidateMode.always,
                          keyboardType: TextInputType.text,
                          style: TextStyle(color: Colors.black, fontSize: 16),
                          onChanged: (value) {
                            profileValue.about = value;
                          },
                          decoration:
                              getInputDecoration(context, 'About', _focusAbout),
                        ),
                        TextFormField(
                          focusNode: _focusEmail,
                          initialValue: profileValue.user.emailAddress,
                          autovalidateMode: AutovalidateMode.always,
                          validator: (value) {
                            if (value != null &&
                                value.isNotEmpty &&
                                !RegExp(AppConstants.EMAIL_REGEX)
                                    .hasMatch(value)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
                          style: TextStyle(color: Colors.black, fontSize: 16),
                          onChanged: (value) {
                            profileValue.user.emailAddress = value;
                          },
                          decoration:
                              getInputDecoration(context, 'Email', _focusEmail),
                        ),
                        DateTimeField(
                          focusNode: _focusDateOfBirth,
                          decoration: getInputDecoration(
                              context, 'Date of Birth', _focusDateOfBirth),
                          format: DateFormat(AppConstants.HEADER_DATE_FORMAT),
                          autovalidate: true,
                          initialValue: profileValue.dateOfBirth,
                          onShowPicker: (context, currentValue) {
                            return showDatePicker(
                                builder: (BuildContext context, Widget child) {
                                  return Theme(
                                    data: ThemeData.light().copyWith(
                                      colorScheme: ColorScheme.light().copyWith(
                                        primary: Theme.of(context).accentColor,
                                      ),
                                      primaryColor:
                                          Colors.red, //Head background
                                      accentColor: Colors.red, //selection color
                                      dialogBackgroundColor:
                                          Colors.white, //Background color
                                    ),
                                    child: child,
                                  );
                                },
                                context: context,
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                                initialDate: currentValue ?? DateTime.now());
                          },
                          onChanged: (value) {
                            profileValue.dateOfBirth = value;
                          },
                        ),
                        TextFormField(
                          focusNode: _focusProfession,
                          initialValue: profileValue.profession,
                          autovalidateMode: AutovalidateMode.always,
                          validator: (value) {
                            if (value != null &&
                                value.isNotEmpty &&
                                !RegExp(AppConstants.NO_SPECIAL_CHARACTER_REGEX)
                                    .hasMatch(value)) {
                              return 'Invalid';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
                          style: TextStyle(color: Colors.black, fontSize: 16),
                          onChanged: (value) {
                            profileValue.profession = value;
                          },
                          decoration: getInputDecoration(
                              context, 'Profession', _focusProfession),
                        ),
                        DropdownButtonFormField<Gender>(
                          icon: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 12.0, 0),
                            child: Icon(Icons.keyboard_arrow_down),
                          ),
                          items: AppConstants.genderList.map((gender) {
                            return new DropdownMenuItem<Gender>(
                                value: gender,
                                child: Row(
                                  children: <Widget>[
                                    Row(
                                      children: [
                                        gender.iconKey != null
                                            ? Icon(MdiIcons.fromString(
                                                gender.iconKey))
                                            : EmptyWidget(),
                                        Text(gender.name),
                                      ],
                                    ),
                                  ],
                                ));
                          }).toList(),
                          onChanged: (value) {
                            profileValue.gender = value;
                          },
                          value: profileValue.gender,
                          decoration: InputDecoration(
                            errorStyle: TextStyle(fontSize: 12),
                            enabledBorder: InputBorder.none,
                            fillColor: Colors.lightBlueAccent,
                            labelText: 'Gender',
                            labelStyle: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 16),
                          ),
                        ),
                        CheckboxSelectBottomSheet(
                          label: 'Interested in',
                          labelColor: Theme.of(context).primaryColor,
                          values: profileValue.interestedIn,
                          onChange: (value) =>
                              profileValue.interestedIn = value,
                          options: AppConstants.genderList
                              .where(
                                  (element) => element.name != 'Not disclosed')
                              .toList(),
                          valueColor: Colors.black,
                          inputDecoration: getInputDecoration(
                              context, 'Interested in', null),
                        ),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ButtonTheme(
                                minWidth:
                                    (MediaQuery.of(context).size.width / 2) -
                                        30,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.white)),
                                  onPressed: widget.resetCallback,
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              ButtonTheme(
                                minWidth:
                                    (MediaQuery.of(context).size.width / 2) -
                                        30,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Theme.of(context).primaryColor)),
                                  onPressed: save,
                                  child: Text(
                                    'Save',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ExpansionTile(
                          title: Text("Connect with social"),
                          children: [
                            SignInButton(
                              Buttons.Google,
                              onPressed: () {
                                widget.linkWithSocialCallback('google');
                              },
                              text: 'Link with Google',
                            ),
                            SignInButton(
                              Buttons.Facebook,
                              onPressed: () {
                                widget.linkWithSocialCallback('facebook');
                              },
                              text: 'Link with Facebook',
                            )
                          ],
                        )
                      ],
                    )),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> selectImage(UserProfile userProfile, File file) async {
    Color themeColor = Theme.of(context).primaryColor;
    if (file == null) {
      return;
    }
    File croppedImage = await ic.ImageCropper.cropImage(
      sourcePath: file.path,
      maxWidth: 1080,
      maxHeight: 1080,
      aspectRatio: ic.CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      androidUiSettings: ic.AndroidUiSettings(
          toolbarTitle: 'Preview',
          toolbarColor: themeColor,
          toolbarWidgetColor: Colors.white),
    );
    if (croppedImage != null) {
      final mediaParse = MediaParse(
        file: ParseFile(croppedImage),
        mediaType: 'PHOTO',
      );
      await mediaParse.setThumbnail(tempDirectory.path, uuid.v1());
      await mediaParse.setDominantColor();

      final pictureCollection = userProfile.profilePictureCollection ??
          MediaCollectionParse(
            code: uuid.v1(),
            name: 'Profile Pictures',
            mediaType: 'PHOTO',
            module: 'PROFILE_PICTURE',
            user: (await ParseUser.currentUser()) as ParseUser,
          );
      userProfile.profilePicture = mediaParse;
      widget.profilePictureChangeCallback(MediaCollectionMappingParse(
        collection: MediaCollectionParse(
          code: pictureCollection.code,
          id: pictureCollection.id,
          isActive: pictureCollection.isActive,
          mediaType: pictureCollection.mediaType,
          module: pictureCollection.module,
          name: pictureCollection.name,
          user: pictureCollection.user,
        ),
        isActive: true,
        media: mediaParse,
      ));
    }
  }

  void save() {
    if (_formKey.currentState.validate()) {
      final user = profileValue.user;
      final UserProfile toBeSavedUserProfile = UserProfileParse(
        about: profileValue.about,
        dateOfBirth: profileValue.dateOfBirth,
        firstName: profileValue.firstName,
        lastName: profileValue.lastName,
        gender: profileValue.gender,
        id: profileValue.id,
        interestedIn: profileValue.interestedIn,
        isActive: profileValue.isActive,
        profession: profileValue.profession,
        profilePicture: profileValue.profilePicture,
        user: user,
        archiveMemoryCollection: profileValue.archiveMemoryCollection,
        profilePictureCollection: profileValue.profilePictureCollection,
      );
      widget.saveCallback(toBeSavedUserProfile);
    }
  }

  IconButton getSuffixIcon(FocusNode _focus) {
    IconButton icon = IconButton(
      icon: Icon(
        Icons.edit,
        size: 18,
      ),
      onPressed: () {
        if (_focus != null) {
          _focus.unfocus();
        }
      },
    );
    return icon;
  }

  InputDecoration getInputDecoration(
      BuildContext context, String label, FocusNode focusNode) {
    return InputDecoration(
      errorStyle: TextStyle(fontSize: 12),
      enabledBorder: InputBorder.none,
      suffixIcon: getSuffixIcon(focusNode),
      fillColor: Colors.lightBlueAccent,
      labelText: label,
      labelStyle:
          TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
    );
  }
}
