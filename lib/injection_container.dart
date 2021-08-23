import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mood_manager/core/util/time_zone.dart';
import 'package:mood_manager/features/auth/data/datasources/auth_data_source.dart';
import 'package:mood_manager/features/auth/data/datasources/parse/auth_parse_data_source.dart';
import 'package:mood_manager/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mood_manager/features/auth/domain/repositories/auth_repository.dart';
import 'package:mood_manager/features/auth/domain/usecases/get_current_user.dart';
import 'package:mood_manager/features/auth/domain/usecases/is_signed_in.dart';
import 'package:mood_manager/features/auth/domain/usecases/is_username_exist.dart';
import 'package:mood_manager/features/auth/domain/usecases/is_user_exist.dart';
import 'package:mood_manager/features/auth/domain/usecases/sign_in_with_credentials.dart';
import 'package:mood_manager/features/auth/domain/usecases/sign_in_with_facebook.dart';
import 'package:mood_manager/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:mood_manager/features/auth/domain/usecases/sign_out.dart';
import 'package:mood_manager/features/auth/domain/usecases/sign_up.dart';
import 'package:mood_manager/features/auth/presentation/bloc/authentication_bloc.dart';
import 'package:mood_manager/features/auth/presentation/bloc/login_bloc.dart';
import 'package:mood_manager/features/auth/presentation/bloc/signup_bloc.dart';
import 'package:mood_manager/features/common/data/datasources/common_remote_data_source.dart';
import 'package:mood_manager/features/common/data/datasources/media_file_service.dart';
import 'package:mood_manager/features/memory/data/datasources/memory_remote_data_source.dart';
import 'package:mood_manager/features/memory/data/repositories/memory_repository.dart';
import 'package:mood_manager/features/memory/domain/repositories/memory_repository_impl.dart';
import 'package:mood_manager/features/memory/domain/usecases/add_memory_to_collection.dart';
import 'package:mood_manager/features/memory/domain/usecases/archive_memory.dart';
import 'package:mood_manager/features/memory/domain/usecases/get_archive_memory_list.dart';
import 'package:mood_manager/features/memory/domain/usecases/get_media_collection_list.dart';
import 'package:mood_manager/features/memory/domain/usecases/get_memory_collection_list.dart';
import 'package:mood_manager/features/memory/domain/usecases/get_memory_list.dart';
import 'package:mood_manager/features/memory/domain/usecases/get_memory_list_by_collection.dart';
import 'package:mood_manager/features/memory/domain/usecases/get_memory_list_by_date.dart';
import 'package:mood_manager/features/memory/domain/usecases/get_memory_list_by_media.dart';
import 'package:mood_manager/features/memory/domain/usecases/get_single_memory.dart';
import 'package:mood_manager/features/memory/domain/usecases/save_memory_collection.dart';
import 'package:mood_manager/features/metadata/domain/usecases/add_activity.dart';
import 'package:mood_manager/features/memory/domain/usecases/save_memory.dart';
import 'package:mood_manager/features/memory/presentation/bloc/memory_bloc.dart';
import 'package:mood_manager/features/metadata/data/datasources/m_activity_remote_data_source.dart';
import 'package:mood_manager/features/metadata/domain/usecases/get_activity_list.dart';
import 'package:mood_manager/features/metadata/domain/usecases/search_activity_list.dart';
import 'package:mood_manager/features/metadata/presentation/bloc/activity_bloc.dart';
import 'package:mood_manager/features/mood_manager/data/datasources/rest_countries.dart';
import 'package:mood_manager/features/profile/data/datasources/user_profile_remote_data_source.dart';
import 'package:mood_manager/features/metadata/data/repositories/m_activity_repository_impl.dart';
import 'package:mood_manager/features/profile/data/repositories/user_profile_repository_impl.dart';
import 'package:mood_manager/features/metadata/domain/repositories/m_activity_repository.dart';
import 'package:mood_manager/features/profile/domain/repositories/user_profile_repository.dart';
import 'package:mood_manager/features/profile/domain/usecases/get_current_user_profile.dart';
import 'package:mood_manager/features/metadata/domain/usecases/get_activity_type_list.dart';
import 'package:mood_manager/features/profile/domain/usecases/get_user_profile.dart';
import 'package:mood_manager/features/profile/domain/usecases/link_with_social.dart';
import 'package:mood_manager/features/profile/domain/usecases/save_profile_picture.dart';
import 'package:mood_manager/features/mood_manager/domain/usecases/save_t_mood.dart';
import 'package:mood_manager/features/metadata/data/datasources/m_mood_remote_data_source.dart';
import 'package:mood_manager/features/mood_manager/data/datasources/t_mood_remote_data_source.dart';
import 'package:mood_manager/features/metadata/data/repositories/m_mood_repository_impl.dart';
import 'package:mood_manager/features/mood_manager/data/repositories/t_mood_repository_impl.dart';
import 'package:mood_manager/features/metadata/domain/repositories/m_mood_repository.dart';
import 'package:mood_manager/features/mood_manager/domain/repositories/t_mood_repository.dart';
import 'package:mood_manager/features/metadata/domain/usecases/get_m_mood_list.dart';
import 'package:mood_manager/features/mood_manager/domain/usecases/get_t_mood_list.dart';
import 'package:mood_manager/features/profile/domain/usecases/save_user_profile.dart';
import 'package:mood_manager/features/mood_manager/presentation/bloc/activity_list_index.dart';
import 'package:mood_manager/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:mood_manager/features/mood_manager/presentation/bloc/t_mood_index.dart';
import 'package:mood_manager/features/mood_manager/presentation/bloc/mood_circle_index.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:mood_manager/features/reminder/data/datasources/task_notification_remote_data_source.dart';
import 'package:mood_manager/features/reminder/data/datasources/task_remote_data_source.dart';
import 'package:mood_manager/features/reminder/data/repositories/task_repository.dart';
import 'package:mood_manager/features/reminder/domain/repositories/task_repository_impl.dart';
import 'package:mood_manager/features/reminder/domain/usecases/get_memory_list.dart';
import 'package:mood_manager/features/reminder/domain/usecases/save_memory.dart';
import 'package:mood_manager/features/reminder/presentation/bloc/task_bloc.dart';
import 'package:mood_manager/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_trimmer/video_trimmer.dart';

import 'core/network/network_info.dart';
import 'core/util/input_converter.dart';
import 'package:timezone/timezone.dart' as tz;

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Number Trivia
  // Bloc
  sl.registerFactory(() => MoodCircleBloc(
        getMoodMetaList: sl(),
      ));
  sl.registerFactory(() => ActivityListBloc(
        getMActivityTypeList: sl(),
      ));
  sl.registerFactory(() => TMoodBloc(saveTMood: sl(), getTMoodList: sl()));
  sl.registerFactory(() => AuthenticationBloc(
      isSignedIn: sl(), getCurrentUser: sl(), signOut: sl()));
  sl.registerFactory(() => LoginBloc(
      signInWithCredentials: sl(),
      signInWithGoogle: sl(),
      signInWithFacebook: sl()));
  sl.registerFactory(() => SignupBloc(
        signUp: sl(),
        isUserExist: sl(),
        isUsernameExist: sl(),
      ));
  sl.registerFactory(() => ProfileBloc(
      getCurrentUserProfile: sl(),
      getUserProfile: sl(),
      saveUserProfile: sl(),
      saveProfilePicture: sl(),
      linkWithSocial: sl()));
  sl.registerFactory(() => MemoryBloc(
        saveMemory: sl(),
        addActivity: sl(),
        getMemoryList: sl(),
        getMemoryListByDate: sl(),
        getArchiveMemoryList: sl(),
        archiveMemory: sl(),
        getMemoryCollectionList: sl(),
        addMemoryToCollection: sl(),
        getMemoryListByCollection: sl(),
        getMediaCollectionList: sl(),
        getMemoryListByMedia: sl(),
        getSingleMemory: sl(),
        saveMemoryCollection: sl(),
      ));

  sl.registerFactory(() => ActivityBloc(
        getActivityList: sl(),
        getActivityTypeList: sl(),
        addActivity: sl(),
        searchActivityList: sl(),
      ));
  sl.registerFactory(() => TaskBloc(
        getTaskList: sl(),
        saveTask: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetMMoodList(sl()));
  sl.registerLazySingleton(() => GetTMoodList(sl()));
  sl.registerLazySingleton(() => SaveTMood(sl()));
  sl.registerLazySingleton(() => GetActivityTypeList(sl()));
  sl.registerLazySingleton(() => GetActivityList(sl()));
  sl.registerLazySingleton(() => SearchActivityList(sl()));

  sl.registerLazySingleton(() => IsSignedIn(sl()));
  sl.registerLazySingleton(() => SignInWithCredentials(sl()));
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => SignInWithFacebook(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => SignUp(sl()));
  sl.registerLazySingleton(() => IsUserExist(sl()));
  sl.registerLazySingleton(() => IsUsernameExist(sl()));

  sl.registerLazySingleton(() => GetCurrentUserProfile(sl()));
  sl.registerLazySingleton(() => GetUserProfile(sl()));
  sl.registerLazySingleton(() => SaveUserProfile(sl()));
  sl.registerLazySingleton(() => SaveProfilePicture(sl()));
  sl.registerLazySingleton(() => LinkWithSocial(sl()));

  sl.registerLazySingleton(() => SaveMemory(sl()));
  sl.registerLazySingleton(() => AddActivity(sl()));
  sl.registerLazySingleton(() => GetMemoryList(sl()));
  sl.registerLazySingleton(() => GetMemoryListByDate(sl()));
  sl.registerLazySingleton(() => GetArchiveMemoryList(sl()));
  sl.registerLazySingleton(() => ArchiveMemory(sl()));
  sl.registerLazySingleton(() => GetMemoryCollectionList(sl()));
  sl.registerLazySingleton(() => AddMemoryToCollection(sl()));
  sl.registerLazySingleton(() => GetMemoryListByCollection(sl()));
  sl.registerLazySingleton(() => GetMediaCollectionList(sl()));
  sl.registerLazySingleton(() => GetMemoryListByMedia(sl()));
  sl.registerLazySingleton(() => GetSingleMemory(sl()));
  sl.registerLazySingleton(() => SaveMemoryCollection(sl()));

  sl.registerLazySingleton(() => SaveTask(sl()));
  sl.registerLazySingleton(() => GetTaskList(sl()));
  // Repository
  sl.registerLazySingleton<MMoodRepository>(() => MMoodRepositoryImpl(
      remoteDataSource: sl(), commomRemoteDataSource: sl()));
  sl.registerLazySingleton<TMoodRepository>(
    () => TMoodRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<MActivityRepository>(
    () => MActivityRepositoryImpl(
      remoteDataSource: sl(),
      commonRemoteDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(dataSource: sl(), commonRemoteDataSource: sl()),
  );
  sl.registerLazySingleton<UserProfileRepository>(
    () => UserProfileRepositoryImpl(
        remoteDataSource: sl(),
        commonRemoteDataSource: sl(),
        authRemoteDataSource: sl()),
  );
  sl.registerLazySingleton<MemoryRepository>(
    () => MemoryRepositoryImpl(
      remoteDataSource: sl(),
      commonRemoteDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(
        remoteDataSource: sl(), commonRemoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<MMoodRemoteDataSource>(
    () => MMoodParseDataSource(),
  );
  sl.registerLazySingleton<TMoodRemoteDataSource>(
    () => TMoodParseDataSource(),
  );
  sl.registerLazySingleton<MActivityRemoteDataSource>(
      () => MActivityParseDataSource());
  sl.registerLazySingleton<AuthDataSource>(
    () => AuthParseDataSource(
      firebaseAuth: sl(),
      googleSignin: sl(),
      facebookLogin: sl(),
      httpClient: sl(),
      userProfileRemoteDataSource: sl(),
      uuid: sl(),
    ),
  );
  sl.registerLazySingleton<UserProfileRemoteDataSource>(
    () => UserProfileParseDataSource(
      commonRemoteDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<MemoryRemoteDataSource>(
    () => MemoryParseDataSource(
      commonParseDataSource: sl(),
      userProfileRemoteDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<CommonRemoteDataSource>(
    () => CommonParseDataSource(networkInfo: sl()),
  );
  sl.registerLazySingleton<TaskRemoteDataSource>(
    () => TaskParseDataSource(
      taskNotificationSource: sl(),
      memoryRemoteDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<TaskNotificationRemoteDataSource>(
    () => TaskNotificationRemoteDataSourceImpl(
      flutterLocalNotificationsPlugin: sl(),
      notificationDetails: sl(),
      locationFuture: sl(),
    ),
  );
  sl.registerLazySingleton<MediaFileService>(
    () => MediaFileService(
      imagePicker: sl(),
      tempDirectory: sl('tempDirectory'),
      uuid: sl(),
      videoInfo: sl(),
    ),
  );

  //! Core
  sl.registerLazySingleton(() => InputConverter());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  //! External
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => DataConnectionChecker());
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => GoogleSignIn());
  sl.registerLazySingleton(() => FacebookLogin());
  sl.registerLazySingleton(
      () => RestCountries.setup('d2b3ecd3f68f52fa52225702e328769e'));
  sl.registerLazySingleton(() => ImagePicker());
  sl.registerLazySingleton(() => FlutterVideoInfo());
  sl.registerLazySingleton(() => Trimmer());
  sl.registerLazySingleton(() => Uuid());
  sl.registerLazySingleton(() => AndroidInitializationSettings('app_icon'));
  sl.registerLazySingleton(() => IOSInitializationSettings());
  sl.registerLazySingleton(
      () => InitializationSettings(android: sl(), iOS: sl()));
  sl.registerLazySingleton(() => AndroidNotificationDetails(
      "myChannelId", "myChannel", "This is my channel",
      importance: Importance.max));
  sl.registerLazySingleton(() => IOSNotificationDetails());
  sl.registerLazySingleton(() => NotificationDetails(android: sl(), iOS: sl()));
  sl.registerLazySingleton(() {
    var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    /*flutterLocalNotificationsPlugin.initialize(sl(),
        onSelectNotification: (value) {
      print('Notification tapped ->' + value);
      return;
    });*/
    return flutterLocalNotificationsPlugin;
  });
  sl.registerLazySingleton<Future<tz.Location>>(() async {
    return await getLocation();
  });
  getTemporaryDirectory().then((value) =>
      sl.registerLazySingleton(() => value, instanceName: 'tempDirectory'));
}

getLocation() async {
  final timeZone = TimeZone();
  String timeZoneName = await timeZone.getTimeZoneName();
  final location = await timeZone.getLocation(timeZoneName);
  return location;
}
