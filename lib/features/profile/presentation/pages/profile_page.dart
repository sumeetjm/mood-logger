import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  @override
  void initState() {
    super.initState();
    this._profileBloc = BlocProvider.of<ProfileBloc>(context);
    this._commonRemoteDataSource = sl<CommonRemoteDataSource>();
    _profileBloc.add(GetCurrentUserProfileEvent());
    countMap['tasks'] = sl<TaskRemoteDataSource>().getTotalNoOfTasks();
    countMap['media'] = _commonRemoteDataSource.getTotalNoOfPhotos();
    countMap['memories'] = sl<MemoryRemoteDataSource>().getTotalNoOfMemories();
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
            _profileBloc.add(GetCurrentUserProfileEvent());
          } else if (state is UserProfileSaving) {
            userProfile = state.userProfile;
          } else if (state is UserProfileLoading) {}
          handleLoader(state, context);
        },
        builder: (context, state) {
          if (userProfile == null) {
            return EmptyWidget();
          } else {
            return ProfileView(
              value: userProfile,
              countMap: countMap,
              saveCallback: save,
              resetCallback: () {
                setState(() {});
              },
              profilePictureChangeCallback: (profilePicture) {
                profilePicChange(profilePictureMediaCollection: profilePicture);
              },
              onPictureTapCallback: () async {
                if (userProfile.profilePicture != null) {
                  final mediaListByCollectionCallback = _commonRemoteDataSource
                      .getMediaCollectionMappingByCollection(
                          userProfile.profilePictureCollection,
                          priorityMedia: userProfile.profilePicture);
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return MediaPageView(
                      initialItem: MediaCollectionMapping(
                          collection: userProfile.profilePictureCollection,
                          media: userProfile.profilePicture),
                      future: mediaListByCollectionCallback,
                    );
                  }));
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
  }

  void linkWithSocial(String social) {
    _profileBloc.add(LinkWithSocialEvent(social));
  }
}
