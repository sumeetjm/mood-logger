import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_page_transition/flutter_page_transition.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mood_manager/core/constants/app_constants.dart';
import 'package:mood_manager/core/util/date_util.dart';
import 'package:mood_manager/core/util/hex_color.dart'; ////
import 'package:mood_manager/destination_view.dart';
import 'package:mood_manager/features/about/presentation/pages/about_page.dart';
import 'package:mood_manager/features/auth/presentation/bloc/authentication_bloc.dart';
import 'package:mood_manager/features/auth/presentation/splash_page.dart';
import 'package:mood_manager/features/memory/presentation/bloc/memory_bloc.dart';
import 'package:mood_manager/features/memory/presentation/pages/fab_menu.dart';
import 'package:mood_manager/features/memory/presentation/pages/memory_calendar_page.dart';
import 'package:mood_manager/features/memory/presentation/pages/memory_collection_list_page.dart';
import 'package:mood_manager/features/memory/presentation/pages/memory_form_page.dart';
import 'package:mood_manager/features/memory/presentation/pages/memory_list_page.dart';
import 'package:mood_manager/features/memory/presentation/pages/media_collection_grid_page.dart';
import 'package:mood_manager/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:mood_manager/features/reminder/data/datasources/task_remote_data_source.dart';
import 'package:mood_manager/features/reminder/data/models/task_notification_mapping_parse.dart';
import 'package:mood_manager/features/reminder/data/models/task_parse.dart';
import 'package:mood_manager/features/reminder/domain/entities/task_notification_mapping.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:mood_manager/features/reminder/presentation/bloc/task_bloc.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:provider/provider.dart';
import 'package:tinycolor/tinycolor.dart';

import 'features/auth/presentation/login_page.dart';
import 'features/auth/presentation/signup_page.dart';
import 'features/memory/presentation/widgets/transparent_page_route.dart';
import 'features/reminder/data/datasources/task_notification_remote_data_source.dart';
import 'features/reminder/presentation/pages/task_form_page.dart';
import 'features/reminder/presentation/pages/task_view_page.dart';

const List<String> allDestinations = [
  '/profile',
  '/list',
  '/calendar',
  '/task',
];

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<Home> with TickerProviderStateMixin<Home> {
  List<GlobalKey<NavigatorState>> _destinationKeys;
  List<AnimationController> _faders;
  int _currentIndex = 1;
  AnimationController _hide;
  GlobalKey<NavigatorState> appNavigatorKey;
  GlobalKey<ScaffoldState> scaffoldKey;
  MemoryBloc memoryBloc;
  GlobalKey<FancyFabState> fabKey;
  DateTime currentBackPressTime;
  DateTime memoryCalendarSelectedDate;
  DateTime taskCalendarSelectedDate;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  TaskNotificationRemoteDataSource _taskNotificationRemoteDataSource;

  @override
  void initState() {
    super.initState();
    appNavigatorKey = GlobalKey<NavigatorState>();
    scaffoldKey = GlobalKey<ScaffoldState>();
    fabKey = GlobalKey<FancyFabState>();
    _taskNotificationRemoteDataSource = sl<TaskNotificationRemoteDataSource>();
    _faders = allDestinations
        .map((index) =>
            AnimationController(vsync: this, duration: Duration(seconds: 1)))
        .toList();
    _faders[_currentIndex].value = 1.0;
    _destinationKeys =
        allDestinations.map((index) => GlobalKey<NavigatorState>()).toList();
    _hide = AnimationController(
        vsync: this, duration: kThemeAnimationDuration, value: 1);
    memoryBloc = sl<MemoryBloc>();
    BackButtonInterceptor.add(myInterceptor);
    flutterLocalNotificationsPlugin = sl<FlutterLocalNotificationsPlugin>();
    flutterLocalNotificationsPlugin.initialize(sl(),
        onSelectNotification: openTaskNotification);
    notifyTask();
  }

  Future<dynamic> openTaskNotification(taskNotificationMappingId) async {
    if(taskNotificationMappingId != null){
      setState(() {
        _currentIndex = 3;
      });
      TaskNotificationMappingParse taskNotificationMappingParse =
          await _taskNotificationRemoteDataSource
              .getTaskNotificationMappingByNotificationmappingId(
                  taskNotificationMappingId);

      Navigator.of(appNavigatorKey.currentContext).push(TransparentRoute(
        builder: (context) {
          return TaskViewPage(
            taskNotificationMappingList: [taskNotificationMappingParse],
            theme: Theme.of(context),
          );
        },
      ));
    }

    return;
  }

  notifyTask() async {
    final notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails.didNotificationLaunchApp) {
      openTaskNotification(notificationAppLaunchDetails.payload);
    }
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    print("BACK BUTTON!"); // Do some stuff.
    return EasyLoading.isShow;
  }

  setMemoryCalendarSelectedDate(DateTime date) {
    this.memoryCalendarSelectedDate = date;
  }

  setTaskCalendarSelectedDate(DateTime date) {
    this.taskCalendarSelectedDate = date;
  }

  setTaskCalendarTab() {
    setState(() {
      _currentIndex = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    final destinationIndex = allDestinations.asMap().keys.toList();
    var primaryColor = HexColor.fromHex('#131945');
    var accentColor = HexColor.fromHex('#ec8a5e');
    var buttonColor = TinyColor(accentColor).lighten(30).color;
    return MultiProvider(
      providers: [
        Provider<GlobalKey<NavigatorState>>(
          create: (context) => appNavigatorKey,
        ),
        Provider<GlobalKey<ScaffoldState>>(
          create: (context) => scaffoldKey,
        ),
        Provider<GlobalKey<FancyFabState>>(
          create: (context) => fabKey,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ProfileBloc>(
            create: (BuildContext context) => sl<ProfileBloc>(),
          ),
          BlocProvider<MemoryBloc>(
            create: (BuildContext context) {
              return memoryBloc;
            },
          ),
          BlocProvider<TaskBloc>(
            create: (BuildContext context) => sl<TaskBloc>(),
          ),
        ],
        child: MaterialApp(
          builder: EasyLoading.init(),
          navigatorKey: appNavigatorKey,
          title: 'Mood Manager',
          theme: ThemeData(
            primaryColor: primaryColor,
            accentColor: accentColor,
            buttonColor: buttonColor,
          ),
          onGenerateRoute: (RouteSettings settings) {
            return PageRouteBuilder<dynamic>(
                settings: settings,
                pageBuilder: (BuildContext context, Animation<double> animation,
                    Animation<double> secondaryAnimation) {
                  switch (settings.name) {
                    case '/memory/add':
                      return MemoryFormPage(arguments: settings.arguments);
                      break;
                    case '/memory/list/archive':
                      return MemoryListPage(
                        arguments: {
                          'listType': 'ARCHIVE',
                          'title': 'Archived memories',
                          'saveCallback': () {
                            memoryBloc.add(GetMemoryListEvent());
                          }
                        },
                        showMenuButton: false,
                      );
                      break;
                    case '/memory/collection/list':
                      return MemoryCollectionListPage();
                      break;
                    case '/memory/list/collection':
                      return MemoryListPage(
                        arguments: settings.arguments,
                        showMenuButton: false,
                      );
                      break;
                    case '/about':
                      return AboutPage();
                      break;
                    case '/media/collection/list':
                      return MediaCollectionGridPage();
                      break;
                    case '/memory/list':
                      return MemoryListPage(arguments: settings.arguments);
                      break;
                    default:
                      return MemoryCalendarPage(arguments: settings.arguments);
                  }
                },
                transitionDuration: const Duration(milliseconds: 600),
                transitionsBuilder: (BuildContext context,
                    Animation<double> animation,
                    Animation<double> secondaryAnimation,
                    Widget child) {
                  return effectMap[
                          (settings.arguments as Map ?? {})['transitionType'] ??
                              PageTransitionType.slideInLeft](
                      Curves.linear, animation, secondaryAnimation, child);
                });
          },
          home: WillPopScope(
            onWillPop: () async {
              final maybePop =
                  await _destinationKeys[_currentIndex].currentState.maybePop();
              if (!maybePop) {
                DateTime now = DateTime.now();
                if (currentBackPressTime == null ||
                    now.difference(currentBackPressTime) >
                        Duration(seconds: 2)) {
                  currentBackPressTime = now;
                  Fluttertoast.showToast(
                      gravity: ToastGravity.TOP,
                      msg: "Press back again to exit",
                      backgroundColor: accentColor);
                  return Future.value(false);
                }
                return Future.value(true);
              }
              return false;
            },
            child: Scaffold(
                floatingActionButton: FancyFab(
                  key: fabKey,
                  icon: Icons.calendar_today,
                  onPressed: () {},
                  addMemory: () async {
                    setState(() {
                      _currentIndex = 1;
                    });
                    await Navigator.of(appNavigatorKey.currentContext)
                        .pushNamed('/memory/add', arguments: {
                      'selectedDate':
                          memoryCalendarSelectedDate ?? DateTime.now()
                    });
                  },
                  addTask: () async {
                    setState(() {
                      _currentIndex = 3;
                    });
                    if (taskCalendarSelectedDate != null &&
                        taskCalendarSelectedDate.isBefore(DateTime.now())) {
                      taskCalendarSelectedDate = null;
                    }
                    await Navigator.of(appNavigatorKey.currentContext)
                        .push(TransparentRoute(
                      builder: (context) {
                        return TaskFormPage(
                          selectedDate:
                              taskCalendarSelectedDate ?? DateTime.now(),
                          theme: Theme.of(context),
                        );
                      },
                    ));
                  },
                ),
                key: scaffoldKey,
                drawer: Drawer(
                  child: Container(
                    color: TinyColor(Colors.grey).lighten(35).color,
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: <Widget>[
                        Container(
                          color: Colors.white,
                          height: 30,
                        ),
                        Builder(
                          builder: (context) {
                            return BlocBuilder(
                              cubit: BlocProvider.of<ProfileBloc>(context),
                              builder: (context, state) {
                                if (state is UserProfileLoaded ||
                                    state is UserProfileSaved) {
                                  ImageProvider image;
                                  if (state.userProfile?.profilePicture?.file
                                          ?.url !=
                                      null) {
                                    image = NetworkImage(state.userProfile
                                        ?.profilePicture?.file?.url);
                                  } else if (state.userProfile?.profilePicture
                                          ?.file?.file?.path !=
                                      null) {
                                    image = FileImage(state.userProfile
                                        ?.profilePicture?.file?.file);
                                  } else {
                                    image = NetworkImage(
                                        AppConstants.DEFAULT_PROFILE_PIC);
                                  }
                                  return Container(
                                    color: Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: CircleAvatar(
                                                        radius: 40,
                                                        backgroundColor:
                                                            Colors.white,
                                                        child: CircleAvatar(
                                                          backgroundImage:
                                                              image,
                                                          radius: 37,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                ListTile(
                                                  title: Text(
                                                    (state.userProfile
                                                                ?.firstName ??
                                                            '') +
                                                        " " +
                                                        (state.userProfile
                                                                ?.lastName ??
                                                            ''),
                                                  ),
                                                  subtitle: Text(state
                                                      .userProfile
                                                      .user
                                                      .emailAddress),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                return CircleAvatar(
                                  radius: 28,
                                  child: Icon(Icons.ac_unit_outlined),
                                );
                              },
                            );
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.perm_identity_outlined,
                            color: accentColor,
                          ),
                          title: Text('View profile'),
                          onTap: () {
                            setState(() {
                              _currentIndex =
                                  allDestinations.indexOf('/profile');
                            });
                            scaffoldKey.currentState.openEndDrawer();
                          },
                        ),
                        Divider(
                          thickness: 0,
                          height: 0,
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.archive_outlined,
                            color: accentColor,
                          ),
                          title: Text('Archive'),
                          onTap: () {
                            Navigator.of(appNavigatorKey.currentContext)
                                .pushNamed('/memory/list/archive');
                          },
                        ),
                        Divider(
                          thickness: 0,
                          height: 0,
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.collections_outlined,
                            color: accentColor,
                          ),
                          title: Text('Your collection'),
                          onTap: () {
                            Navigator.of(appNavigatorKey.currentContext)
                                .pushNamed('/memory/collection/list');
                          },
                        ),
                        Divider(
                          thickness: 0,
                          height: 0,
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.perm_media_outlined,
                            color: accentColor,
                          ),
                          title: Text('Photos & Videos'),
                          onTap: () {
                            Navigator.of(appNavigatorKey.currentContext)
                                .pushNamed('/media/collection/list');
                          },
                        ),
                        Divider(
                          thickness: 0,
                          height: 0,
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.info_outline,
                            color: accentColor,
                          ),
                          title: Text('About'),
                          onTap: () {
                            Navigator.of(appNavigatorKey.currentContext)
                                .pushNamed('/about');
                          },
                        ),
                        Divider(
                          thickness: 0,
                          height: 0,
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.logout,
                            color: accentColor,
                          ),
                          title: Text('Log out'),
                          onTap: () {
                            BlocProvider.of<AuthenticationBloc>(context)
                                .add(LoggedOut());
                          },
                        ),
                        Divider(
                          thickness: 0,
                          height: 0,
                        ),
                      ],
                    ),
                  ),
                ),
                body: SafeArea(
                  top: false,
                  child: Stack(
                    fit: StackFit.expand,
                    children: destinationIndex.map((int index) {
                      final Widget view = FadeTransition(
                        opacity: _faders[index]
                            .drive(CurveTween(curve: Curves.fastOutSlowIn)),
                        child: DestinationView(
                          navigatorKey: _destinationKeys[index],
                          currentRoute: allDestinations[index],
                          onNavigation: () async {
                            await _hide.reverse();
                          },
                          unhideBottomNavigation: () async {
                            await _hide.forward();
                          },
                          handleScrollNotification: _handleScrollNotification,
                        ),
                      );
                      if (index == _currentIndex) {
                        _faders[index].forward();
                        return view;
                      } else {
                        _faders[index].reverse();
                        if (_faders[index].isAnimating) {
                          return IgnorePointer(child: view);
                        }
                        return Offstage(child: view);
                      }
                    }).toList(),
                  ),
                ),
                bottomNavigationBar: SizeTransition(
                  sizeFactor: _hide,
                  axisAlignment: -1.25,
                  child: BottomAppBar(
                    color: primaryColor,
                    child: Container(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: IconButton(
                              icon: Icon(Icons.perm_identity),
                              color: _currentIndex == 0
                                  ? accentColor
                                  : Colors.white.withOpacity(0.4),
                              onPressed: () {
                                fabKey.currentState.close();
                                //sl<FlutterLocalNotificationsPlugin>()
                                //   .show(0, 'title', 'body', sl<NotificationDetails>());
                                setState(() {
                                  _currentIndex = 0;
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: IconButton(
                              icon: Icon(Icons.list),
                              color: _currentIndex == 1
                                  ? accentColor
                                  : Colors.white.withOpacity(0.4),
                              onPressed: () {
                                fabKey.currentState.close();
                                //sl<FlutterLocalNotificationsPlugin>()
                                //   .show(0, 'title', 'body', sl<NotificationDetails>());
                                setState(() {
                                  _currentIndex = 1;
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: IconButton(
                                icon: Icon(MdiIcons.calendarMonth),
                                color: _currentIndex == 2
                                    ? accentColor
                                    : Colors.white.withOpacity(0.4),
                                onPressed: () {
                                  fabKey.currentState.close();
                                  //sl<FlutterLocalNotificationsPlugin>()
                                  //   .show(0, 'title', 'body', sl<NotificationDetails>());
                                  setState(() {
                                    _currentIndex = 2;
                                  });
                                }),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: IconButton(
                              icon: Icon(Icons.list_alt_rounded),
                              color: _currentIndex == 3
                                  ? accentColor
                                  : Colors.white.withOpacity(0.4),
                              onPressed: () {
                                fabKey.currentState.close();
                                //sl<FlutterLocalNotificationsPlugin>()
                                //   .show(0, 'title', 'body', sl<NotificationDetails>());
                                setState(() {
                                  _currentIndex = 3;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (AnimationController controller in _faders) controller.dispose();
    super.dispose();
    _hide.dispose();
    BackButtonInterceptor.remove(myInterceptor);
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0) {
      if (notification is UserScrollNotification) {
        final UserScrollNotification userScroll = notification;
        switch (userScroll.direction) {
          case ScrollDirection.forward:
            _hide.forward();
            break;
          case ScrollDirection.reverse:
            _hide.reverse();
            break;
          case ScrollDirection.idle:
            break;
        }
      }
    }
    return false;
  }

  Future notificationSelected(String payload) async {
    Navigator.of(appNavigatorContext(context)).pushNamed('/about');
  }
}

appNavigatorContext(context) {
  return (Provider.of<GlobalKey<NavigatorState>>(context, listen: false))
      .currentContext;
}
