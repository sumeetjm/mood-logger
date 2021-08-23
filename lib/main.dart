import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mood_manager/auth.dart';
import 'package:mood_manager/features/auth/presentation/bloc/authentication_bloc.dart';
import 'package:mood_manager/features/auth/presentation/splash_page.dart';
import 'package:mood_manager/features/common/domain/entities/media.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection_mapping.dart';
import 'package:mood_manager/features/common/presentation/widgets/custom_animation.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:mood_manager/features/memory/domain/entities/memory_collection.dart';
import 'package:mood_manager/features/metadata/domain/entities/gender.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_activity_type.dart';
import 'package:mood_manager/features/metadata/domain/entities/m_mood.dart';
import 'package:mood_manager/features/profile/domain/entities/user_profile.dart';
import 'package:mood_manager/features/reminder/domain/entities/task.dart';
import 'package:mood_manager/features/reminder/domain/entities/task_memory_mapping.dart';
import 'package:mood_manager/features/reminder/domain/entities/task_notification_mapping.dart';
import 'package:mood_manager/features/reminder/domain/entities/task_repeat.dart';
import 'package:mood_manager/home.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'injection_container.dart' as di;
import 'package:intl/date_symbol_data_local.dart';
import 'package:hive/hive.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

const String PARSE_APP_ID = 'M6MIrnNIxvQ3pt7JL5ydeaVfeIYdK8GO5y0B9k3N';
const String PARSE_APP_URL = 'https://moodmanager.back4app.io';
const String MASTER_KEY = 'QuamKAN1Lyv7Z9YLUgvfVVcEF0cZBJrjCDYcIy55';
const String LIVE_QUERY_URL = 'https://moodmanager.back4app.io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  await di.init();

  await Parse().initialize(
    PARSE_APP_ID,
    PARSE_APP_URL,
    masterKey: MASTER_KEY,
    liveQueryUrl: LIVE_QUERY_URL,
    autoSendSessionId: true,
    debug: true,
    coreStore: CoreStoreMemoryImp(),
    fileDirectory: (await getTemporaryDirectory()).path,
  );
  /*ParseInstallation installation =
      await ParseInstallation.currentInstallation();
  installation.set("GCMSenderId", "206555785179");
  await installation.save();*/
  final document = await getApplicationDocumentsDirectory();
  Hive
    ..init(document.path)
    ..registerAdapter(MMoodAdapter())
    ..registerAdapter(MActivityAdapter())
    ..registerAdapter(MActivityTypeAdapter())
    ..registerAdapter(UserProfileAdapter())
    ..registerAdapter(MediaAdapter())
    ..registerAdapter(GenderAdapter())
    ..registerAdapter(MediaCollectionAdapter())
    ..registerAdapter(MemoryCollectionAdapter())
    ..registerAdapter(MediaCollectionMappingAdapter())
    ..registerAdapter(TaskAdapter())
    ..registerAdapter(MemoryAdapter())
    ..registerAdapter(TaskRepeatAdapter())
    ..registerAdapter(TaskMemoryMappingAdapter())
    ..registerAdapter(TaskNotificationMappingAdapter());

  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.dualRing
    ..loadingStyle = EasyLoadingStyle.light
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = false
    ..dismissOnTap = false;
  //..customAnimation = CustomAnimation();

  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  GlobalKey<HomeState> homeKey = GlobalKey();
  AuthenticationBloc _authenticationBloc;
  @override
  void initState() {
    super.initState();
    _authenticationBloc = di.sl<AuthenticationBloc>();
    _authenticationBloc.add(AppStarted());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _authenticationBloc,
      child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        cubit: _authenticationBloc,
        builder: (BuildContext context, AuthenticationState state) {
          if (state is Unauthenticated) {
            return AuthApp();
          } else if (state is Authenticated) {
            return MultiProvider(
                providers: [Provider.value(value: homeKey)],
                child: Home(
                  key: homeKey,
                ));
          } else {
            return MaterialApp(
              home: SplashPage(),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
