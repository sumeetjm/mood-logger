import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_page_transition/flutter_page_transition.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mood_manager/core/constants/app_constants.dart';
import 'package:mood_manager/core/util/hex_color.dart';
import 'package:mood_manager/destination_view.dart';
import 'package:mood_manager/features/about/presentation/pages/about_page.dart';
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
    _hide = AnimationController(vsync: this, duration: kThemeAnimationDuration);
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
            final memoryBloc = sl<MemoryBloc>();
            memoryBloc.add(GetMemoryListEvent());
            return memoryBloc;
          },
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
                      'title': 'Archived memories'
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
          onWillPop: () async =>
              !await _destinationKeys[_currentIndex].currentState.maybePop(),
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
                                  state.userProfile.firstName +
                                      " " +
                                      state.userProfile.lastName,
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
}
