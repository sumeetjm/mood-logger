import 'dart:ui';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:mood_manager/core/constants/app_constants.dart';
import 'package:mood_manager/features/common/data/models/media_collection_parse.dart';
import 'package:mood_manager/features/common/data/models/media_parse.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection_mapping.dart';
import 'package:mood_manager/features/profile/data/models/user_profile_parse.dart';
import 'package:mood_manager/features/metadata/domain/entities/gender.dart';
import 'package:mood_manager/features/profile/domain/entities/user_profile.dart';
import 'package:mood_manager/features/common/presentation/widgets/empty_widget.dart';
import 'package:mood_manager/features/common/presentation/widgets/check_box_list_field.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:multi_media_picker/multi_media_picker.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:tinycolor/tinycolor.dart';
import 'dart:io';

import 'package:uuid/uuid.dart';

class ProfileView extends StatelessWidget {
  final ValueChanged<UserProfile> saveCallback;
  final Function resetCallback;
  final ValueChanged<MediaCollectionMapping> profilePictureChangeCallback;
  final Function onPictureTapCallback;
  final ValueChanged<String> linkWithSocialCallback;
  final Uuid uuid = sl<Uuid>();
  ProfileView({
    Key key,
    this.saveCallback,
    this.resetCallback,
    this.profilePictureChangeCallback,
    this.onPictureTapCallback,
    this.linkWithSocialCallback,
  }) : super(key: key);

  String about;
  String email;
  String name;
  DateTime dateOfBirth;
  String profession;
  Gender gender;
  List<Gender> interestedIn;
  bool isChanged = false;

  UserProfile userProfile;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _focusAbout = FocusNode();
  final FocusNode _focusEmail = new FocusNode();
  final FocusNode _focusName = new FocusNode();
  final FocusNode _focusDateOfBirth = new FocusNode();
  final FocusNode _focusProfession = new FocusNode();
  @override
  Widget build(BuildContext context) {
    userProfile = Provider.of<UserProfile>(context);
    this.about = userProfile.about;
    this.name =
        (userProfile.firstName ?? '') + ' ' + (userProfile.lastName ?? '');
    this.dateOfBirth = userProfile.dateOfBirth;
    this.profession = userProfile.profession;
    this.gender = userProfile.gender ??
        AppConstants.genderList.firstWhere((element) => element.isDummy);
    this.interestedIn = userProfile.interestedIn ?? [];
    this.email = userProfile.user.emailAddress;
    ImageProvider image;
    if (userProfile?.profilePicture?.file?.url != null) {
      image = NetworkImage(userProfile?.profilePicture?.file?.url);
    } else if (userProfile?.profilePicture?.file?.file?.path != null) {
      image = FileImage(userProfile?.profilePicture?.file?.file);
    } else {
      image = NetworkImage(AppConstants.DEFAULT_PROFILE_PIC);
    }

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 350.0,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            title: Text(
              name,
              style: TextStyle(fontSize: 16),
            ),
            background: Container(
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
                                    tag: userProfile?.profilePicture?.tag ??
                                        uuid.v1(),
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
                                                        leading:
                                                            Icon(Icons.camera),
                                                        title: Text('Camera'),
                                                        onTap: () => {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(),
                                                              _onImageButtonPressed(
                                                                  ImageSource
                                                                      .camera,
                                                                  userProfile,
                                                                  context:
                                                                      context)
                                                            }),
                                                    ListTile(
                                                      leading: Icon(
                                                          Icons.photo_library),
                                                      title: Text('Gallery'),
                                                      onTap: () => {
                                                        Navigator.of(context)
                                                            .pop(),
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
                            color: TinyColor(Theme.of(context).primaryColor)
                                .lighten(65)
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
                                          'Posts',
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
                                        Text(
                                          '5200',
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            color:
                                                Theme.of(context).primaryColor,
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
                                            color:
                                                Theme.of(context).primaryColor,
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
                                            color:
                                                Theme.of(context).primaryColor,
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
                                            color:
                                                Theme.of(context).primaryColor,
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
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        )
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
              child: ListView(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: [
                  TextFormField(
                    focusNode: _focusName,
                    initialValue: name,
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
                      name = value;
                    },
                    decoration: getInputDecoration(context, 'Name', _focusName),
                  ),
                  TextFormField(
                    focusNode: _focusAbout,
                    initialValue: about,
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
                      isChanged = true;
                      about = value;
                    },
                    decoration:
                        getInputDecoration(context, 'About', _focusAbout),
                  ),
                  TextFormField(
                    focusNode: _focusEmail,
                    initialValue: email,
                    autovalidate: true,
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          !RegExp(AppConstants.EMAIL_REGEX).hasMatch(value)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.text,
                    style: TextStyle(color: Colors.black, fontSize: 16),
                    onChanged: (value) {
                      email = value;
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
                    initialValue: dateOfBirth,
                    onShowPicker: (context, currentValue) {
                      return showDatePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                          initialDate: currentValue ?? DateTime.now());
                    },
                    onChanged: (value) {
                      dateOfBirth = value;
                    },
                  ),
                  TextFormField(
                    focusNode: _focusProfession,
                    initialValue: profession,
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
                      profession = value;
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
                              gender?.iconData != null
                                  ? Icon(gender?.iconData)
                                  : EmptyWidget(),
                              Text(gender.name),
                            ],
                          ));
                    }).toList(),
                    onChanged: (value) {
                      gender = value;
                    },
                    value: gender,
                    decoration: InputDecoration(
                      errorStyle: TextStyle(fontSize: 12),
                      enabledBorder: InputBorder.none,
                      fillColor: Colors.lightBlueAccent,
                      labelText: 'Gender',
                      labelStyle: TextStyle(
                          color: Theme.of(context).primaryColor, fontSize: 16),
                    ),
                  ),
                  CheckboxSelectBottomSheet(
                    label: 'Interested in',
                    labelColor: Theme.of(context).primaryColor,
                    values: interestedIn,
                    onChange: (value) => interestedIn = value,
                    options: AppConstants.genderList,
                    valueColor: Colors.black,
                    inputDecoration:
                        getInputDecoration(context, 'Interested in', null),
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ButtonTheme(
                          minWidth:
                              (MediaQuery.of(context).size.width / 2) - 30,
                          child: RaisedButton(
                            onPressed: resetCallback,
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor),
                            ),
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        ButtonTheme(
                          minWidth:
                              (MediaQuery.of(context).size.width / 2) - 30,
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
                  ),
                  ExpansionTile(
                    title: Text("Connect with social"),
                    children: [
                      SignInButton(
                        Buttons.Google,
                        onPressed: () {
                          linkWithSocialCallback('google');
                        },
                        text: 'Link with Google',
                      ),
                      SignInButton(
                        Buttons.Facebook,
                        onPressed: () {
                          linkWithSocialCallback('facebook');
                        },
                        text: 'Link with Facebook',
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );

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
                                tag: userProfile.profilePicture.tag,
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
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          focusNode: _focusName,
                          initialValue: name,
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
                          style: TextStyle(color: Colors.white, fontSize: 20),
                          onChanged: (value) {
                            name = value;
                          },
                          decoration: InputDecoration(
                            errorStyle: TextStyle(fontSize: 12),
                            border: InputBorder.none,
                            // suffixIcon: getSuffixIcon(_focusName),
                            fillColor: Colors.lightBlueAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
        Container(
          padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  focusNode: _focusAbout,
                  initialValue: about,
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
                    isChanged = true;
                    about = value;
                  },
                  decoration: getInputDecoration(context, 'About', _focusAbout),
                ),
                TextFormField(
                  focusNode: _focusEmail,
                  initialValue: email,
                  autovalidate: true,
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        !RegExp(AppConstants.EMAIL_REGEX).hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  onChanged: (value) {
                    email = value;
                  },
                  decoration: getInputDecoration(context, 'Email', _focusEmail),
                ),
                TextFormField(
                  focusNode: _focusName,
                  initialValue: name,
                  autovalidate: true,
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
                    name = value;
                  },
                  decoration: getInputDecoration(context, 'Name', _focusName),
                ),
                DateTimeField(
                  focusNode: _focusDateOfBirth,
                  decoration: getInputDecoration(
                      context, 'Date of Birth', _focusDateOfBirth),
                  format: DateFormat(AppConstants.HEADER_DATE_FORMAT),
                  autovalidate: true,
                  initialValue: dateOfBirth,
                  onShowPicker: (context, currentValue) {
                    return showDatePicker(
                        context: context,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                        initialDate: currentValue ?? DateTime.now());
                  },
                  onChanged: (value) {
                    dateOfBirth = value;
                  },
                ),
                TextFormField(
                  focusNode: _focusProfession,
                  initialValue: profession,
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
                    profession = value;
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
                            gender?.iconData != null
                                ? Icon(gender?.iconData)
                                : EmptyWidget(),
                            Text(gender.name),
                          ],
                        ));
                  }).toList(),
                  onChanged: (value) {
                    gender = value;
                  },
                  value: gender,
                  decoration: InputDecoration(
                    errorStyle: TextStyle(fontSize: 12),
                    enabledBorder: InputBorder.none,
                    fillColor: Colors.lightBlueAccent,
                    labelText: 'Gender',
                    labelStyle: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 16),
                  ),
                ),
                CheckboxSelectBottomSheet(
                  label: 'Interested in',
                  labelColor: Theme.of(context).primaryColor,
                  values: interestedIn,
                  onChange: (value) => interestedIn = value,
                  options: AppConstants.genderList,
                  valueColor: Colors.black,
                  inputDecoration:
                      getInputDecoration(context, 'Interested in', null),
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ButtonTheme(
                        minWidth: (MediaQuery.of(context).size.width / 2) - 30,
                        child: RaisedButton(
                          onPressed: resetCallback,
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
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
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _onImageButtonPressed(ImageSource source, UserProfile userProfile,
      {BuildContext context}) async {
    Color themeColor = Theme.of(context).primaryColor;
    final cacheDir = await getTemporaryDirectory();
    try {
      final pickedFileList =
          await MultiMediaPicker.pickImages(source: source, singleImage: true);
      File croppedImage = await ImageCropper.cropImage(
        sourcePath: pickedFileList[0].path,
        maxWidth: 1080,
        maxHeight: 1080,
        aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Preview',
            toolbarColor: themeColor,
            toolbarWidgetColor: Colors.white),
      );
      if (croppedImage != null) {
        final thumbnailImage = img.copyResize(
            img.decodeImage(croppedImage.readAsBytesSync()),
            width: 200);
        final thumbnailFile = File(cacheDir.path + "/" + uuid.v1() + ".jpg");
        thumbnailFile.writeAsBytesSync(img.encodeJpg(thumbnailImage));
        final pictureCollection =
            userProfile.profilePictureCollection?.incrementMediaCount() ??
                MediaCollectionParse(
                  code: uuid.v1(),
                  name: 'Profile Pictures',
                  mediaType: 'PHOTO',
                  module: 'PROFILE_PICTURE',
                  mediaCount: 1,
                  user: (await ParseUser.currentUser()) as ParseUser,
                );
        final profilePicture = MediaParse(
          mediaType: "PHOTO",
          file: ParseFile(croppedImage),
          thumbnail: ParseFile(thumbnailFile),
        );
        profilePictureChangeCallback(MediaCollectionMapping(
          collection: pictureCollection,
          isActive: true,
          media: profilePicture,
        ));
      }
    } catch (e) {
      print(e);
    }
  }

  void save() {
    if (_formKey.currentState.validate()) {
      var names = name
          .split(' ')
          .where((element) => element.trim().isNotEmpty)
          .toList();
      final user = userProfile.user;
      user.emailAddress = email;
      final UserProfile toBeSavedUserProfile = UserProfileParse(
        about: about,
        dateOfBirth: dateOfBirth,
        firstName: names.removeAt(0),
        lastName: names.join(' '),
        gender: gender,
        id: userProfile.id,
        interestedIn: interestedIn,
        isActive: userProfile.isActive,
        profession: profession,
        profilePicture: userProfile.profilePicture,
        user: user,
      );
      saveCallback(toBeSavedUserProfile);
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
