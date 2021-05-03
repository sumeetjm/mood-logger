import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_page_transition/flutter_page_transition.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mood_manager/core/constants/app_constants.dart';
import 'package:mood_manager/core/util/hex_color.dart';
import 'package:mood_manager/destination_view.dart';
import 'package:mood_manager/features/about/presentation/pages/about_page.dart';
import 'package:mood_manager/features/auth/presentation/bloc/authentication_bloc.dart';
import 'package:mood_manager/features/common/presentation/widgets/loading_bar.dart';
import 'package:mood_manager/features/memory/presentation/bloc/memory_bloc.dart';
import 'package:mood_manager/features/memory/presentation/pages/memory_calendar_page.dart';
import 'package:mood_manager/features/memory/presentation/pages/memory_collection_list_page.dart';
import 'package:mood_manager/features/memory/presentation/pages/memory_form_page.dart';
import 'package:mood_manager/features/memory/presentation/pages/memory_list_page.dart';
import 'package:mood_manager/features/memory/presentation/pages/media_collection_grid_page.dart';
import 'package:mood_manager/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:mood_manager/features/profile/presentation/pages/profile_page.dart';
import 'package:mood_manager/features/mood_manager/presentation/bloc/t_mood_index.dart';
import 'package:mood_manager/features/mood_manager/presentation/pages/activity_form_page.dart';
import 'package:mood_manager/features/mood_manager/presentation/pages/mood_form_page.dart';
import 'package:mood_manager/features/mood_manager/presentation/pages/t_mood_list_page.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:mood_manager/features/reminder/presentation/bloc/task_bloc.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

const List<String> allDestinations = [
  '/profile',
  '/list',
  // '/form',
  '/calendar',
  '/more',
];

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin<Home> {
  TMoodBloc tMoodBloc;
  List<GlobalKey<NavigatorState>> _destinationKeys;
  List<GlobalKey<NavigatorState>> _destinationViewKeys;
  List<AnimationController> _faders;
  int _currentIndex = 1;
  AnimationController _hide;
  GlobalKey<NavigatorState> appNavigatorKey;
  GlobalKey<ScaffoldState> scaffoldKey;
  FlutterLocalNotificationsPlugin flutterNotification;
  final memoryBloc = sl<MemoryBloc>();

  @override
  void initState() {
    super.initState();
    tMoodBloc = sl<TMoodBloc>();
    appNavigatorKey = GlobalKey<NavigatorState>();
    scaffoldKey = GlobalKey<ScaffoldState>();
    _faders = allDestinations
        .map((index) =>
            AnimationController(vsync: this, duration: Duration(seconds: 1)))
        .toList();
    _faders[_currentIndex].value = 1.0;
    _destinationKeys =
        allDestinations.map((index) => GlobalKey<NavigatorState>()).toList();
    _destinationViewKeys =
        allDestinations.map((index) => GlobalKey<NavigatorState>()).toList();
    _hide = AnimationController(
        vsync: this, duration: kThemeAnimationDuration, value: 1);

    var androidInitilize = new AndroidInitializationSettings('app_icon');
    var iOSinitilize = new IOSInitializationSettings();
    var initilizationsSettings = new InitializationSettings(
        android: androidInitilize, iOS: iOSinitilize);
    flutterNotification = new FlutterLocalNotificationsPlugin();
    flutterNotification.initialize(initilizationsSettings,
        onSelectNotification: notificationSelected);
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  Widget build(BuildContext context) {
    var keys = allDestinations.asMap().keys.toList();
    return MultiBlocProvider(
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
        navigatorKey: appNavigatorKey,
        title: 'Mood Manager',
        theme: ThemeData(
            primaryColor: HexColor.fromHex('#272f63'),
            accentColor: HexColor.fromHex('#272f63'),
            buttonColor: Colors.blueGrey[800]),
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
                    return MemoryListPage(arguments: {
                      'listType': 'ARCHIVE',
                      'title': 'Archived memories',
                      'saveCallback': () {
                        memoryBloc.add(GetMemoryListEvent());
                      }
                    });
                    break;
                  case '/memory/collection/list':
                    return MemoryCollectionListPage();
                    break;
                  case '/memory/list/collection':
                    return MemoryListPage(arguments: settings.arguments);
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
            /*{
            return (await showDialog(
                  context: context,
                  builder: (context) => new AlertDialog(
                    title: new Text('Are you sure?'),
                    content: new Text('Do you want to exit an App'),
                    actions: <Widget>[
                      new FlatButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: new Text('No'),
                      ),
                      new FlatButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: new Text('Yes'),
                      ),
                    ],
                  ),
                )) ??
                false;
          },*/
            var maybePop =
                await _destinationKeys[_currentIndex].currentState.maybePop();
            return !maybePop;
          },
          child: Scaffold(
            key: scaffoldKey,
            drawer: Drawer(
              child: ListView(
                // Important: Remove any padding from the ListView.
                padding: EdgeInsets.zero,
                children: <Widget>[
                  Container(
                    height: 30,
                    color: HexColor.fromHex('#272f63'),
                  ),
                  Builder(
                    builder: (context) {
                      return BlocBuilder(
                        cubit: BlocProvider.of<ProfileBloc>(context),
                        builder: (context, state) {
                          if (state is UserProfileLoaded ||
                              state is UserProfileSaved) {
                            ImageProvider image;
                            if (state.userProfile?.profilePicture?.file?.url !=
                                null) {
                              image = NetworkImage(
                                  state.userProfile?.profilePicture?.file?.url);
                            } else if (state.userProfile?.profilePicture?.file
                                    ?.file?.path !=
                                null) {
                              image = FileImage(state
                                  .userProfile?.profilePicture?.file?.file);
                            } else {
                              image = NetworkImage(
                                  AppConstants.DEFAULT_PROFILE_PIC);
                            }
                            return ListTile(
                                contentPadding: EdgeInsets.all(8),
                                tileColor: HexColor.fromHex('#272f63'),
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.white,
                                  child: CircleAvatar(
                                    backgroundImage: image,
                                    radius: 26,
                                  ),
                                ),
                                title: Text(
                                  (state.userProfile?.firstName ?? '') +
                                      " " +
                                      (state.userProfile?.lastName ?? ''),
                                  style: TextStyle(color: Colors.white),
                                ),
                                onTap: () {
                                  setState(() {
                                    _currentIndex =
                                        allDestinations.indexOf('/profile');
                                  });
                                  scaffoldKey.currentState.openEndDrawer();
                                });
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
                    title: Text('Archive'),
                    onTap: () {
                      Navigator.of(appNavigatorKey.currentContext)
                          .pushNamed('/memory/list/archive');
                    },
                  ),
                  ListTile(
                    title: Text('Your collection'),
                    onTap: () {
                      Navigator.of(appNavigatorKey.currentContext)
                          .pushNamed('/memory/collection/list');
                    },
                  ),
                  ListTile(
                    title: Text('All media'),
                    onTap: () {
                      Navigator.of(appNavigatorKey.currentContext)
                          .pushNamed('/media/collection/list');
                    },
                  ),
                  ListTile(
                    title: Text('About'),
                    onTap: () {
                      Navigator.of(appNavigatorKey.currentContext)
                          .pushNamed('/about');
                    },
                  ),
                  ListTile(
                    title: Text('Log out'),
                    onTap: () {
                      BlocProvider.of<AuthenticationBloc>(context)
                          .add(LoggedOut());
                    },
                  ),
                ],
              ),
            ),
            body: SafeArea(
              top: false,
              child: Stack(
                fit: StackFit.expand,
                children: keys.map((int index) {
                  final Widget view = FadeTransition(
                    opacity: _faders[index]
                        .drive(CurveTween(curve: Curves.fastOutSlowIn)),
                    child: DestinationView(
                      key: _destinationViewKeys[index],
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
              child: BottomNavigationBar(
                backgroundColor: HexColor.fromHex('#272f63'),
                currentIndex: _currentIndex,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white.withOpacity(0.5),
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.perm_identity,
                    ),
                    label: 'Profile',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.list,
                    ),
                    label: 'List',
                  ),
                  /*     BottomNavigationBarItem(
                    icon: Icon(
                      Icons.add_circle,
                      size: 40,
                    ),
                    label: '',
                  ),*/
                  BottomNavigationBarItem(
                    icon: Icon(
                      MdiIcons.calendarMonth,
                    ),
                    label: 'Calendar',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.more_horiz,
                    ),
                    label: 'More',
                  ),
                ],
                onTap: (int index) {
                  //sl<FlutterLocalNotificationsPlugin>()
                  //   .show(0, 'title', 'body', sl<NotificationDetails>());
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
    return MaterialApp(
      title: 'Mood Manager',
      theme: ThemeData(
          primaryColor: HexColor.fromHex('#272f63'),
          accentColor: HexColor.fromHex('#272f63'),
          buttonColor: Colors.blueGrey[800]),
      home: Scaffold(
        body: Navigator(
          onGenerateRoute: (RouteSettings settings) {
            return PageRouteBuilder<dynamic>(
                settings: settings,
                pageBuilder: (BuildContext context, Animation<double> animation,
                    Animation<double> secondaryAnimation) {
                  switch (settings.name) {
                    case '/trans-list':
                      return TMoodListPage(arguments: settings.arguments);
                      break;
                    case '/add/mood':
                      return MoodFormPage(arguments: settings.arguments);
                      break;
                    case '/add/activity':
                      return ActivityFormPage(arguments: settings.arguments);
                      break;
                    // case '/edit':
                    //   return EditFormPage(arguments: settings.arguments);
                    //   break;
                    case '/profile':
                      return ProfilePage(arguments: settings.arguments);
                      break;
                    case '/add/memory':
                      return MemoryFormPage(arguments: settings.arguments);
                      break;
                    case '/memory/list':
                      return MemoryListPage(arguments: settings.arguments);
                      break;
                    case '/memory/calendar':
                      return MemoryCalendarPage(arguments: settings.arguments);
                      break;
                    case '/memory/add':
                      return MemoryFormPage(arguments: settings.arguments);
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
        ),
        bottomNavigationBar: ClipRect(
          child: SizeTransition(
            sizeFactor: _hide,
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.layers,
                    color: Colors.red,
                  ),
                  label: 'List',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.layers,
                    color: Colors.green,
                  ),
                  label: 'Calendar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.layers,
                    color: Colors.blue,
                  ),
                  label: 'Form',
                ),
              ],
              onTap: (int index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
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
    tMoodBloc.close();
    BackButtonInterceptor.remove(myInterceptor);
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    print("BACK BUTTON!"); // Do some stuff.
    return Loader.isLoading();
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
    Navigator.of(appNavigatorKey.currentContext).pushNamed('/about');
  }
}
