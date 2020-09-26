import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mood_manager/features/auth/data/datasources/auth_data_source.dart';
import 'package:mood_manager/features/auth/data/datasources/firestore/auth_firestore_data_source.dart';
import 'package:mood_manager/features/auth/data/datasources/parse/auth_parse_data_source.dart';
import 'package:mood_manager/features/auth/data/reposotories/auth_repository_impl.dart';
import 'package:mood_manager/features/auth/domain/repositories/auth_repository.dart';
import 'package:mood_manager/features/auth/domain/usecases/get_current_user.dart';
import 'package:mood_manager/features/auth/domain/usecases/is_signed_in.dart';
import 'package:mood_manager/features/auth/domain/usecases/sign_in_with_credentials.dart';
import 'package:mood_manager/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:mood_manager/features/auth/domain/usecases/sign_out.dart';
import 'package:mood_manager/features/auth/domain/usecases/sign_up.dart';
import 'package:mood_manager/features/auth/presentation/bloc/authentication_bloc.dart';
import 'package:mood_manager/features/auth/presentation/bloc/login_bloc.dart';
import 'package:mood_manager/features/auth/presentation/bloc/signup_bloc.dart';
import 'package:mood_manager/features/mood_manager/data/datasources/m_activity_remote_data_source.dart';
import 'package:mood_manager/features/mood_manager/data/datasources/metadata_data_source.dart';
import 'package:mood_manager/features/mood_manager/data/datasources/rest_countries.dart';
import 'package:mood_manager/features/mood_manager/data/datasources/user_profile_remote_data_source.dart';
import 'package:mood_manager/features/mood_manager/data/repositories/m_activity_repository_impl.dart';
import 'package:mood_manager/features/mood_manager/data/repositories/user_profile_repository_impl.dart';
import 'package:mood_manager/features/mood_manager/domain/repositories/m_activity_repository.dart';
import 'package:mood_manager/features/mood_manager/domain/repositories/user_profile_repository.dart';
import 'package:mood_manager/features/mood_manager/domain/usecases/get_current_user_profile.dart';
import 'package:mood_manager/features/mood_manager/domain/usecases/get_m_activity_list.dart';
import 'package:mood_manager/features/mood_manager/domain/usecases/get_user_profile.dart';
import 'package:mood_manager/features/mood_manager/domain/usecases/save_t_mood.dart';
import 'package:mood_manager/features/mood_manager/data/datasources/m_mood_remote_data_source.dart';
import 'package:mood_manager/features/mood_manager/data/datasources/t_mood_remote_data_source.dart';
import 'package:mood_manager/features/mood_manager/data/repositories/m_mood_repository_impl.dart';
import 'package:mood_manager/features/mood_manager/data/repositories/t_mood_repository_impl.dart';
import 'package:mood_manager/features/mood_manager/domain/repositories/m_mood_repository.dart';
import 'package:mood_manager/features/mood_manager/domain/repositories/t_mood_repository.dart';
import 'package:mood_manager/features/mood_manager/domain/usecases/get_m_mood_list.dart';
import 'package:mood_manager/features/mood_manager/domain/usecases/get_t_mood_list.dart';
import 'package:mood_manager/features/mood_manager/domain/usecases/save_user_profile.dart';
import 'package:mood_manager/features/mood_manager/presentation/bloc/activity_list_index.dart';
import 'package:mood_manager/features/mood_manager/presentation/bloc/profile_bloc.dart';
import 'package:mood_manager/features/mood_manager/presentation/bloc/t_mood_index.dart';
import 'package:mood_manager/features/mood_manager/presentation/bloc/mood_circle_index.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import 'core/network/network_info.dart';
import 'core/util/input_converter.dart';

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
  sl.registerFactory(
      () => LoginBloc(signInWithCredentials: sl(), signInWithGoogle: sl()));
  sl.registerFactory(() => SignupBloc(signUp: sl()));
  sl.registerFactory(() => ProfileBloc(
        getCurrentUserProfile: sl(),
        getUserProfile: sl(),
        saveUserProfile: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetMMoodList(sl()));
  sl.registerLazySingleton(() => GetTMoodList(sl()));
  sl.registerLazySingleton(() => SaveTMood(sl()));
  sl.registerLazySingleton(() => GetMActivityTypeList(sl()));

  sl.registerLazySingleton(() => IsSignedIn(sl()));
  sl.registerLazySingleton(() => SignInWithCredentials(sl()));
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => SignUp(sl()));

  sl.registerLazySingleton(() => GetCurrentUserProfile(sl()));
  sl.registerLazySingleton(() => GetUserProfile(sl()));
  sl.registerLazySingleton(() => SaveUserProfile(sl()));

  // Repository
  sl.registerLazySingleton<MMoodRepository>(
    () => MMoodRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<TMoodRepository>(
    () => TMoodRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<MActivityRepository>(
    () => MActivityRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(dataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<UserProfileRepository>(
    () => UserProfileRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data sources
  sl.registerLazySingleton<MMoodRemoteDataSource>(
    () => MMoodParseDataSource(),
  );
  sl.registerLazySingleton<TMoodRemoteDataSource>(
    () => TMoodParseDataSource(),
  );
  sl.registerLazySingleton<MActivityRemoteDataSource>(
    () => MActivityParseDataSource(),
  );
  sl.registerLazySingleton<AuthDataSource>(
    () => AuthParseDataSource(),
  );
  sl.registerLazySingleton<UserProfileRemoteDataSource>(
    () => UserProfileParseDataSource(metadataSource: sl()),
  );
  sl.registerLazySingleton<MetadataRemoteDataSource>(
    () => MetadataRemoteDataSourceImpl(restCountries: sl()),
  );

  //! Core
  sl.registerLazySingleton(() => InputConverter());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  //! External
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => DataConnectionChecker());
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => GoogleSignIn());
  sl.registerLazySingleton(
      () => RestCountries.setup('d2b3ecd3f68f52fa52225702e328769e'));
}
