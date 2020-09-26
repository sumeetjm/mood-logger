import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mood_manager/core/constants/app_constants.dart';
import 'package:mood_manager/features/mood_manager/data/models/parse/album_parse.dart';
import 'package:mood_manager/features/mood_manager/data/models/parse/album_type_parse.dart';
import 'package:mood_manager/features/mood_manager/data/models/parse/photo_parse.dart';
import 'package:mood_manager/features/mood_manager/data/models/parse/user_profile_parse.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/album.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/album_type.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/user_profile.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/date_edit_field.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/select_edit_popup_field.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/text_edit_field.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class ProfileView extends StatelessWidget {
  final Function saveCallback;
  final ValueChanged<UserProfile> onChangeCallback;
  final Function onPictureTapCallback;
  final AlbumType dpAlbumType =
      AlbumTypeParse(name: 'Display Picture', code: 'DP', id: 'iZlMon9iCK');
  final String dpAlbumName = 'Profile Pictures';

  ProfileView({
    Key key,
    this.saveCallback,
    this.onChangeCallback,
    this.onPictureTapCallback,
  }) : super(key: key);
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final userProfile = Provider.of<UserProfile>(context);
    ImageProvider image;
    if (userProfile?.profilePicture?.image?.url != null) {
      image = NetworkImage(userProfile?.profilePicture?.image?.url);
    } else if (userProfile?.profilePicture?.image?.file?.path != null) {
      image = FileImage(userProfile?.profilePicture?.image?.file);
    } else {
      image = NetworkImage(AppConstants.DEFAULT_PROFILE_PIC);
    }
    return ListView(
      children: <Widget>[
        Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: image,
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
                              onTap: onPictureTapCallback,
                              child: Hero(
                                tag: userProfile.profilePicture.id ?? '',
                                child: CircleAvatar(
                                  backgroundImage: image,
                                  radius: 60.0,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
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
                                                    leading: Icon(Icons.camera),
                                                    title: Text('Camera'),
                                                    onTap: () => {
                                                          Navigator.of(context)
                                                              .pop(),
                                                          _onImageButtonPressed(
                                                              ImageSource
                                                                  .camera,
                                                              userProfile,
                                                              context: context)
                                                        }),
                                                ListTile(
                                                  leading:
                                                      Icon(Icons.photo_library),
                                                  title: Text('Gallery'),
                                                  onTap: () => {
                                                    Navigator.of(context).pop(),
                                                    _onImageButtonPressed(
                                                        ImageSource.gallery,
                                                        userProfile,
                                                        context: context)
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        });
                                  }),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Card(
                        margin: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 5.0),
                        clipBehavior: Clip.antiAlias,
                        color: Colors.white,
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
                                      'Posts',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Text(
                                      '5200',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      'Likes',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Text(
                                      '28.5K',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      'Followers',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Text(
                                      '1300',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )),
        Container(
          padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextEditField(
                label: 'About',
                labelColor: Theme.of(context).primaryColor,
                valueColor: Colors.black,
                value: userProfile.about,
                onChange: (value) {
                  final userProfileParse = UserProfileParse(
                    about: value.trim(),
                    city: userProfile.city,
                    country: userProfile.country,
                    dateOfBirth: userProfile.dateOfBirth,
                    firstName: userProfile.firstName,
                    id: userProfile.id,
                    isActive: userProfile.isActive,
                    lastName: userProfile.lastName,
                    profession: userProfile.profession,
                    profilePicture: userProfile.profilePicture,
                    region: userProfile.region,
                    user: userProfile.user,
                  );
                  onChangeCallback(userProfileParse);
                },
                save: saveCallback,
              ),
              TextEditField(
                label: 'Email',
                labelColor: Theme.of(context).primaryColor,
                valueColor: Colors.black,
                value: userProfile.user.emailAddress,
                onChange: (value) {
                  userProfile.user.emailAddress = value.trim();
                },
                save: saveCallback,
                inputType: TextInputType.emailAddress,
              ),
              TextEditField(
                label: 'Name',
                labelColor: Theme.of(context).primaryColor,
                valueColor: Colors.black,
                value: userProfile.firstName + ' ' + userProfile.lastName,
                onChange: (value) {
                  final values = value
                      .split(' ')
                      .where((element) => element.isNotEmpty)
                      .toList();
                  final userProfileParse = UserProfileParse(
                    about: userProfile.about,
                    city: userProfile.city,
                    country: userProfile.country,
                    dateOfBirth: userProfile.dateOfBirth,
                    firstName: values.removeAt(0).trim(),
                    id: userProfile.id,
                    isActive: userProfile.isActive,
                    lastName: values.join(' ').trim(),
                    profession: userProfile.profession,
                    profilePicture: userProfile.profilePicture,
                    region: userProfile.region,
                    user: userProfile.user,
                  );
                  onChangeCallback(userProfileParse);
                },
                save: saveCallback,
              ),
              DateEditField(
                label: 'Date of Birth',
                labelColor: Theme.of(context).primaryColor,
                valueColor: Colors.black,
                value: userProfile.dateOfBirth,
                onChange: (value) {
                  final userProfileParse = UserProfileParse(
                    about: userProfile.about,
                    city: userProfile.city,
                    country: userProfile.country,
                    dateOfBirth: value,
                    firstName: userProfile.firstName,
                    id: userProfile.id,
                    isActive: userProfile.isActive,
                    lastName: userProfile.lastName,
                    profession: userProfile.profession,
                    profilePicture: userProfile.profilePicture,
                    region: userProfile.region,
                    user: userProfile.user,
                  );
                  saveCallback(userProfileFromCallback: userProfileParse);
                },
              ),
              TextEditField(
                label: 'Profession',
                labelColor: Theme.of(context).primaryColor,
                valueColor: Colors.black,
                value: userProfile.profession,
                onChange: (value) {
                  final userProfileParse = UserProfileParse(
                    about: userProfile.about,
                    city: userProfile.city,
                    country: userProfile.country,
                    dateOfBirth: userProfile.dateOfBirth,
                    firstName: userProfile.firstName,
                    id: userProfile.id,
                    isActive: userProfile.isActive,
                    lastName: userProfile.lastName,
                    profession: value.trim(),
                    profilePicture: userProfile.profilePicture,
                    region: userProfile.region,
                    user: userProfile.user,
                  );
                  onChangeCallback(userProfileParse);
                },
                save: saveCallback,
              ),
              TextEditField(
                label: 'Lives In',
                labelColor: Theme.of(context).primaryColor,
                valueColor: Colors.black,
                value: userProfile.city == null
                    ? ''
                    : userProfile.city.city +
                        ', ' +
                        userProfile.city.region +
                        ', ' +
                        userProfile.city.country,
                onChange: (value) {
                  final userProfileParse = UserProfileParse(
                    about: userProfile.about,
                    city: userProfile.city,
                    country: userProfile.country,
                    dateOfBirth: userProfile.dateOfBirth,
                    firstName: userProfile.firstName,
                    id: userProfile.id,
                    isActive: userProfile.isActive,
                    lastName: userProfile.lastName,
                    profession: userProfile.profession,
                    profilePicture: userProfile.profilePicture,
                    region: userProfile.region,
                    user: userProfile.user,
                  );
                  onChangeCallback(userProfileParse);
                },
                save: saveCallback,
              ),
              SelectEditBottomSheetField(
                label: 'Gender',
                labelColor: Theme.of(context).primaryColor,
                valueColor: Colors.black,
                value: userProfile.gender,
                onChange: (value) {
                  final userProfileParse = UserProfileParse(
                    about: userProfile.about,
                    city: userProfile.city,
                    country: userProfile.country,
                    dateOfBirth: userProfile.dateOfBirth,
                    firstName: userProfile.firstName,
                    id: userProfile.id,
                    isActive: userProfile.isActive,
                    lastName: userProfile.lastName,
                    profession: userProfile.profession,
                    profilePicture: userProfile.profilePicture,
                    region: userProfile.region,
                    user: userProfile.user,
                    gender: value,
                  );
                  //saveCallback(userProfileFromCallback: userProfileParse);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onImageButtonPressed(ImageSource source, UserProfile userProfile,
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
        aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Preview',
            toolbarColor: themeColor,
            toolbarWidgetColor: Colors.white),
      );
      if (croppedImage != null) {
        final photoParse = PhotoParse(
            image: ParseFile(File(croppedImage.path)),
            album: userProfile.profilePicture?.album ??
                AlbumParse(
                    albumType: dpAlbumType,
                    name: dpAlbumName,
                    userProfilePointer: (userProfile as UserProfileParse)
                        .baseParsePointer(userProfile)));
        final userProfileParse = UserProfileParse(
          about: userProfile.about,
          city: userProfile.city,
          country: userProfile.country,
          dateOfBirth: userProfile.dateOfBirth,
          firstName: userProfile.firstName,
          id: userProfile.id,
          isActive: userProfile.isActive,
          lastName: userProfile.lastName,
          profession: userProfile.profession,
          profilePicture: photoParse,
          region: userProfile.region,
          user: userProfile.user,
        );
        saveCallback(userProfileFromCallback: userProfileParse);
      }
    } catch (e) {
      print(e);
    }
  }
}
