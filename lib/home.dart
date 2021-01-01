import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_page_transition/flutter_page_transition.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mood_manager/core/util/hex_color.dart';
import 'package:mood_manager/destination_view.dart';
import 'package:mood_manager/features/memory/presentation/pages/memory_calendar_page.dart';
import 'package:mood_manager/features/memory/presentation/pages/memory_form_page.dart';
import 'package:mood_manager/features/memory/presentation/pages/memory_list_page.dart';
import 'package:mood_manager/features/profile/presentation/pages/profile_page.dart';
import 'package:mood_manager/features/mood_manager/presentation/bloc/t_mood_index.dart';
import 'package:mood_manager/features/mood_manager/presentation/pages/activity_form_page.dart';
import 'package:mood_manager/features/mood_manager/presentation/pages/mood_form_page.dart';
import 'package:mood_manager/features/mood_manager/presentation/pages/t_mood_list_page.dart';
import 'package:mood_manager/features/common/presentation/widgets/image_slider.dart';
import 'package:mood_manager/injection_container.dart';
import 'package:swipedetector/swipedetector.dart';

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

  @override
  void initState() {
    super.initState();
    tMoodBloc = sl<TMoodBloc>();
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

  Future<dynamic> navigateToMemoryForm(
      BuildContext context, Map arguments) async {
    final saved = await Navigator.of(context)
        .pushNamed('/memory/add', arguments: arguments);
    return saved;
  }

  @override
  Widget build(BuildContext context) {
    var keys = allDestinations.asMap().keys.toList();
    return MaterialApp(
      title: 'Mood Manager',
      theme: ThemeData(
          primaryColor: HexColor.fromHex('#272f63'),
          accentColor: HexColor.fromHex('#272f63'),
          buttonColor: Colors.blueGrey[800]),
      onGenerateRoute: (RouteSettings settings) {
        if ('/photo/slider' == settings.name) {
          return MaterialPageRoute(
            builder: (context) {
              return ImageSlider(arguments: settings.arguments);
            },
          );
        }
        return PageRouteBuilder<dynamic>(
            settings: settings,
            pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation) {
              switch (settings.name) {
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
      home: SwipeDetector(
        onSwipeDown: _hide.forward,
        child: WillPopScope(
          onWillPop: () async =>
              !await _destinationKeys[_currentIndex].currentState.maybePop(),
          child: NotificationListener<ScrollNotification>(
            onNotification: _handleScrollNotification,
            child: Scaffold(
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
                        navigateToMemoryForm: navigateToMemoryForm,
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
            if ('/photo/slider' == settings.name) {
              return MaterialPageRoute(
                builder: (context) {
                  return ImageSlider(arguments: settings.arguments);
                },
              );
            }
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
