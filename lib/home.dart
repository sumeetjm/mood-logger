import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_page_transition/flutter_page_transition.dart';
import 'package:mood_manager/core/util/hex_color.dart';
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

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TMoodBloc tMoodBloc;

  @override
  void initState() {
    super.initState();
    tMoodBloc = sl<TMoodBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TMoodBloc>(
      create: (context) => tMoodBloc,
      child: MaterialApp(
          title: 'Mood Manager',
          theme: ThemeData(
              primaryColor: HexColor.fromHex('#272f63'),
              accentColor: HexColor.fromHex('#272f63'),
              buttonColor: Colors.blueGrey[800]),
          home: MemoryListPage(),
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
                    default:
                      return null;
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
          }),
    );
  }

  @override
  void dispose() {
    super.dispose();
    tMoodBloc.close();
  }
}
