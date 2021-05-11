import 'package:flutter/material.dart';
import 'package:flutter_page_transition/flutter_page_transition.dart';
import 'package:mood_manager/features/memory/presentation/pages/memory_calendar_page.dart';
import 'package:mood_manager/features/memory/presentation/pages/memory_form_page.dart';
import 'package:mood_manager/features/memory/presentation/pages/memory_list_page.dart';
import 'package:mood_manager/features/profile/presentation/pages/profile_page.dart';
import 'package:mood_manager/features/reminder/presentation/pages/task_calendar_page.dart';
import 'package:swipedetector/swipedetector.dart';

final tabRoutes = {
  '/profile': (context) => ProfilePage(),
  '/list': (context) => MemoryListPage(),
//  '/form': (context) => MemoryFormPage(),
  '/calendar': (context) => MemoryCalendarPage(),
};

class DestinationView extends StatefulWidget {
  final Function onNavigation;
  final GlobalKey<NavigatorState> navigatorKey;
  final Function unhideBottomNavigation;
  final Function handleScrollNotification;
  DestinationView({
    Key key,
    this.currentRoute,
    this.onNavigation,
    this.navigatorKey,
    this.unhideBottomNavigation,
    this.handleScrollNotification,
  }) : super(key: key);

  final String currentRoute;

  @override
  _DestinationViewState createState() => _DestinationViewState();
}

class _DestinationViewState extends State<DestinationView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: widget.navigatorKey,
      observers: <NavigatorObserver>[
        ViewNavigatorObserver(
          widget.onNavigation,
        )
      ],
      onGenerateRoute: (RouteSettings settings) {
        return PageRouteBuilder<dynamic>(
            settings: settings,
            pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation) {
              switch (settings.name) {
                case '/memory/add':
                  return MemoryFormPage(
                    arguments: settings.arguments,
                  );
                default:
                  switch (widget.currentRoute) {
                    case '/profile':
                      return SwipeDetector(
                        onSwipeUp: widget.unhideBottomNavigation,
                        child: NotificationListener<ScrollNotification>(
                          onNotification: widget.handleScrollNotification,
                          child: ProfilePage(arguments: settings.arguments),
                        ),
                      );
                    case '/list':
                      return SwipeDetector(
                          onSwipeUp: widget.unhideBottomNavigation,
                          child: NotificationListener<ScrollNotification>(
                              onNotification: widget.handleScrollNotification,
                              child: MemoryListPage(
                                arguments: settings.arguments,
                              )));
                    case '/calendar':
                      return SwipeDetector(
                          onSwipeUp: widget.unhideBottomNavigation,
                          child: NotificationListener<ScrollNotification>(
                              onNotification: widget.handleScrollNotification,
                              child: MemoryCalendarPage(
                                arguments: settings.arguments,
                              )));
                    default:
                      return SwipeDetector(
                          onSwipeUp: widget.unhideBottomNavigation,
                          child: NotificationListener<ScrollNotification>(
                              onNotification: widget.handleScrollNotification,
                              child: TaskCalendarPage()));
                  }
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
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class ViewNavigatorObserver extends NavigatorObserver {
  ViewNavigatorObserver(this.onNavigation);

  final Function onNavigation;

  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) async {
    await onNavigation();
  }

  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) async {
    await onNavigation();
  }
}
