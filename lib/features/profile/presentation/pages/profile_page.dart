import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mood_manager/core/constants/app_constants.dart';
import 'package:mood_manager/features/common/data/datasources/common_remote_data_source.dart';
import 'package:mood_manager/features/common/domain/entities/base_states.dart';
import 'package:mood_manager/features/common/domain/entities/media.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection_mapping.dart';
import 'package:mood_manager/features/common/presentation/widgets/empty_widget.dart';
import 'package:mood_manager/features/common/presentation/widgets/media_page_view.dart';
import 'package:mood_manager/features/profile/domain/entities/user_profile.dart';
import 'package:mood_manager/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:mood_manager/features/profile/presentation/widgets/profile_view.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:mood_manager/features/reminder/data/datasources/task_remote_data_source.dart';
import 'package:mood_manager/features/memory/data/datasources/memory_remote_data_source.dart';
import 'package:mood_manager/home.dart';
import 'package:uuid/uuid.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfilePage extends StatefulWidget {
  final Map<dynamic, dynamic> arguments;
  final GlobalKey parentKey;
  ProfilePage({this.arguments, Key key, this.parentKey}) : super(key: key);
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ProfileBloc _profileBloc;
  CommonRemoteDataSource _commonRemoteDataSource;
  UserProfile userProfile;
  List<Media> photoList;
  final Map<String, Future<int>> countMap = {};
  String key;
  List<MediaCollectionMapping> profilePictureCollectionMappingList;
  final uuid = sl<Uuid>();

  @override
  void initState() {
    super.initState();
    this._profileBloc = BlocProvider.of<ProfileBloc>(context);
    this._commonRemoteDataSource = sl<CommonRemoteDataSource>();
    _profileBloc.add(GetCurrentUserProfileEvent());
    getCounts();
    key = uuid.v1();
  }

  getCounts() {
    _commonRemoteDataSource.isConnected().then((value) {
      if (value) {
        countMap['tasks'] = sl<TaskRemoteDataSource>().getTotalNoOfTasks();
        countMap['media'] = _commonRemoteDataSource.getTotalNoOfMedia();
        countMap['memories'] =
            sl<MemoryRemoteDataSource>().getTotalNoOfMemories();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ProfileBloc, ProfileState>(
        cubit: _profileBloc,
        listener: (context, state) {
          if (state is UserProfileLoaded) {
            setState(() {
              userProfile = state.userProfile;
            });
          } else if (state is UserProfileSaved) {
            userProfile = state.userProfile;
            Fluttertoast.showToast(
                gravity: ToastGravity.TOP,
                msg: 'Profile saved successfully',
                backgroundColor: Colors.green);
            _profileBloc.add(GetCurrentUserProfileEvent());
            getCounts();
          } else if (state is UserProfileSaving) {
            userProfile = state.userProfile;
          } else if (state is UserProfileLoading) {
          } else if (state is UserProfileError) {
            Fluttertoast.showToast(
                gravity: ToastGravity.TOP,
                msg: state.message,
                backgroundColor: Colors.red);
          }
          handleLoader(state, context);
        },
        builder: (context, state) {
          if (state is Loading) {
            return EmptyWidget();
          }
          if (userProfile == null) {
            return EmptyWidget();
          } else {
            return ProfileView(
              uniquekey: key,
              value: userProfile,
              countMap: countMap,
              saveCallback: save,
              resetCallback: () {
                setState(() {
                  _profileBloc.add(GetCurrentUserProfileEvent());
                });
              },
              profilePictureChangeCallback: (profilePicture) {
                profilePicChange(profilePictureMediaCollection: profilePicture);
              },
              onPictureTapCallback: () async {
                if (await _commonRemoteDataSource.isConnected()) {
                  if (userProfile.profilePicture != null) {
                    EasyLoading.show(
                        status: "Loading...",
                        maskType: EasyLoadingMaskType.black);
                    profilePictureCollectionMappingList =
                        await _commonRemoteDataSource
                            .getMediaCollectionMappingByCollection(
                                userProfile.profilePictureCollection,
                                priorityMedia: userProfile.profilePicture);
                    EasyLoading.dismiss();
                    if (profilePictureCollectionMappingList.isNotEmpty) {
                      Navigator.of(appNavigatorContext(context))
                          .push(MaterialPageRoute(builder: (context) {
                        return MediaPageView(
                          initialItem: MediaCollectionMapping(
                              collection: userProfile.profilePictureCollection,
                              media: userProfile.profilePicture),
                          mediaCollectionList:
                              profilePictureCollectionMappingList,
                          saveMediaCollectionMappingList:
                              (mediaCollectionMappingList) async {
                            setState(() {
                              profilePictureCollectionMappingList =
                                  mediaCollectionMappingList
                                      .where((element) => element.isActive)
                                      .toList();
                            });
                            EasyLoading.show(
                                status: "Loading...",
                                maskType: EasyLoadingMaskType.black);
                            if (await _commonRemoteDataSource.isConnected()) {
                              await _commonRemoteDataSource
                                  .saveMediaCollectionMappingList(
                                      profilePictureCollectionMappingList);
                              EasyLoading.dismiss();
                              _profileBloc.add(GetCurrentUserProfileEvent());
                            } else {
                              Fluttertoast.showToast(
                                  gravity: ToastGravity.TOP,
                                  msg: 'Unable to connect',
                                  backgroundColor: Colors.red);
                            }
                            if (mediaCollectionMappingList
                                    .any((element) => !element.isActive) &&
                                mediaCollectionMappingList
                                        .firstWhere(
                                            (element) => !element.isActive)
                                        .media ==
                                    userProfile.profilePicture) {
                              userProfile.profilePicture =
                                  AppConstants.DEFAULT_PROFILE_MEDIA;
                              _profileBloc.add(
                                  SaveProfilePictureEvent(null, userProfile));
                            }
                          },
                          setAsProfilePicCallback: (value) {
                            userProfile.profilePicture = value;
                            _profileBloc.add(SaveProfilePictureEvent(null, null,
                                media: value));
                          },
                        );
                      }));
                    } else {
                      Fluttertoast.showToast(
                          gravity: ToastGravity.TOP,
                          msg: 'Album is empty',
                          backgroundColor: Colors.red);
                    }
                  }
                } else {
                  Fluttertoast.showToast(
                      gravity: ToastGravity.TOP,
                      msg: 'Unable to connect',
                      backgroundColor: Colors.red);
                }
              },
              linkWithSocialCallback: linkWithSocial,
            );
          }
        },
      ),
    );
  }

  void save(UserProfile toBeSavedUserProfile) async {
    _profileBloc.add(SaveUserProfileEvent(toBeSavedUserProfile));
  }

  void profilePicChange(
      {MediaCollectionMapping profilePictureMediaCollection}) async {
    _profileBloc.add(
        SaveProfilePictureEvent(profilePictureMediaCollection, userProfile));
    profilePictureCollectionMappingList = null;
  }

  void linkWithSocial(String social) {
    _profileBloc.add(LinkWithSocialEvent(social));
  }
}
