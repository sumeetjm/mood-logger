import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mood_manager/auth.dart';
import 'package:mood_manager/features/auth/presentation/bloc/authentication_bloc.dart';
import 'package:mood_manager/features/auth/presentation/splash_page.dart';
import 'package:mood_manager/home.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'injection_container.dart' as di;
import 'package:intl/date_symbol_data_local.dart';

const String PARSE_APP_ID = 'M6MIrnNIxvQ3pt7JL5ydeaVfeIYdK8GO5y0B9k3N';
const String PARSE_APP_URL = 'https://moodmanager.back4app.io';
const String MASTER_KEY = 'QuamKAN1Lyv7Z9YLUgvfVVcEF0cZBJrjCDYcIy55';
const String LIVE_QUERY_URL = 'https://moodmanager.back4app.io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  await Parse().initialize(
    PARSE_APP_ID,
    PARSE_APP_URL,
    masterKey: MASTER_KEY,
    liveQueryUrl: LIVE_QUERY_URL,
    autoSendSessionId: true,
    debug: true,
    coreStore: await CoreStoreSharedPrefsImp.getInstance(),
  );
  ParseInstallation installation =
      await ParseInstallation.currentInstallation();
  installation.set("GCMSenderId", "206555785179");
  installation.save();
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
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
            return Home();
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
    _authenticationBloc.close();
    super.dispose();
  }
}
