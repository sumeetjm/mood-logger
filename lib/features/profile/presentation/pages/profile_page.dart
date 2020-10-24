import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_page_transition/flutter_page_transition.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mood_manager/features/profile/data/datasources/user_profile_remote_data_source.dart';
import 'package:mood_manager/features/common/domain/entities/media.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/profile/domain/entities/user_profile.dart';
import 'package:mood_manager/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:mood_manager/features/common/presentation/widgets/loading_widget.dart';
import 'package:mood_manager/features/profile/presentation/widgets/profile_view.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  final Map<dynamic, dynamic> arguments;
  ProfilePage({this.arguments});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ProfileBloc _profileBloc;
  UserProfileParseDataSource _userProfileRemoteDataSource;
  UserProfile userProfile;
  List<Media> photoList;

  @override
  void initState() {
    super.initState();
    this._profileBloc = sl<ProfileBloc>();
    this._userProfileRemoteDataSource = sl<UserProfileRemoteDataSource>();
    _profileBloc.add(GetCurrentUserProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ProfileBloc, ProfileState>(
        cubit: _profileBloc,
        listener: (context, state) {
          if (state is UserProfileLoaded) {
            userProfile = state.userProfile;
          } else if (state is UserProfileSaved) {
            userProfile = state.userProfile;
          } else if (state is UserProfileSaving) {
            userProfile = state.userProfile;
          }
        },
        builder: (context, state) {
          if (state is ProfileInitial || state is UserProfileLoading) {
            return LoadingWidget();
          } else if (state is UserProfileLoaded || state is UserProfileSaved) {
            return Provider<UserProfile>(
                create: (_) => userProfile,
                child: ProfileView(
                  saveCallback: save,
                  resetCallback: () {
                    setState(() {});
                  },
                  profilePictureChangeCallback: (profilePicture) {
                    profilePicChange(profilePicture: profilePicture);
                  },
                  onPictureTapCallback: () async {
                    if (userProfile.profilePicture != null) {
                      final mediaListByCollectionCallback =
                          _userProfileRemoteDataSource
                              .getMediaCollectionByCollection(
                                  userProfile.profilePictureCollection,
                                  priorityMedia: userProfile.profilePicture);

                      Navigator.pushNamed(
                        context,
                        '/photo/slider',
                        arguments: {
                          'callback': () => mediaListByCollectionCallback,
                          'initial': MediaCollection(
                              collection: userProfile.profilePictureCollection,
                              media: userProfile.profilePicture),
                          'transitionType': PageTransitionType.fadeIn,
                        },
                      );
                    }
                  },
                ));
          } else if (state is UserProfileSaving ||
              state is ProfilePictureSaving) {
            return wrapWithLoader(Provider<UserProfile>(
                create: (_) => userProfile,
                child: ProfileView(
                    saveCallback: save,
                    profilePictureChangeCallback: (profilePicture) {
                      profilePicChange(profilePicture: profilePicture);
                    })));
          }
          return LoadingWidget();
        },
      ),
    );
  }

  void save(UserProfile toBeSavedUserProfile) {
    _profileBloc.add(SaveUserProfileEvent(toBeSavedUserProfile));
  }

  void profilePicChange({Media profilePicture}) {
    _profileBloc.add(SaveProfilePictureEvent(profilePicture, userProfile));
  }

  wrapWithLoader(Widget widget) {
    return LoadingOverlay(
      color: Theme.of(context).primaryColor,
      isLoading: true,
      child: widget,
      opacity: 0.2,
      progressIndicator: CircularProgressIndicator(),
    );
  }
}
