import 'package:flutter/material.dart';
import 'package:flutter_page_transition/flutter_page_transition.dart';
import 'package:mood_manager/features/common/presentation/widgets/empty_widget.dart';
import 'package:mood_manager/features/memory/presentation/pages/memory_calendar_page.dart';
import 'package:mood_manager/features/memory/presentation/pages/memory_list_page.dart';
import 'package:mood_manager/features/profile/presentation/pages/profile_page.dart';

final tabRoutes = {
  '/profile': (context) => ProfilePage(),
  '/list': (context) => MemoryListPage(),
//  '/form': (context) => MemoryFormPage(),
  '/calendar': (context) => MemoryCalendarPage(),
};

class DestinationView extends StatefulWidget {
  final VoidCallback onNavigation;
  final GlobalKey<NavigatorState> navigatorKey;
  final Function navigateToMemoryForm;
  const DestinationView({
    Key key,
    this.currentRoute,
    this.onNavigation,
    this.navigatorKey,
    this.navigateToMemoryForm,
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
        ViewNavigatorObserver(widget.onNavigation),
      ],
      onGenerateRoute: (RouteSettings settings) {
        return PageRouteBuilder<dynamic>(
            settings: settings,
            pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation) {
              switch (settings.name) {
                default:
                  switch (widget.currentRoute) {
                    case '/profile':
                      return ProfilePage(
                        arguments: settings.arguments,
                        navigateToMemoryForm: (arguments) async {
                          return widget.navigateToMemoryForm(
                              (widget.key as GlobalKey).currentContext,
                              arguments);
                        },
                      );
                    case '/list':
                      return MemoryListPage(
                        arguments: settings.arguments,
                        navigateToMemoryForm: (arguments) async {
                          return widget.navigateToMemoryForm(
                              (widget.key as GlobalKey).currentContext,
                              arguments);
                        },
                      );
                    case '/calendar':
                      return MemoryCalendarPage(
                        arguments: settings.arguments,
                        navigateToMemoryForm: (arguments) async {
                          return widget.navigateToMemoryForm(
                              (widget.key as GlobalKey).currentContext,
                              arguments);
                        },
                      );
                    default:
                      return EmptyWidget();
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

  final VoidCallback onNavigation;

  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    onNavigation();
  }

  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    onNavigation();
  }
}
