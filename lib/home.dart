import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_page_transition/flutter_page_transition.dart';
import 'package:mood_manager/core/util/hex_color.dart';
import 'package:mood_manager/core/util/resource_util.dart';
import 'package:mood_manager/features/mood_manager/presentation/bloc/t_mood_index.dart';
import 'package:mood_manager/features/mood_manager/presentation/pages/activity_form_page.dart';
import 'package:mood_manager/features/mood_manager/presentation/pages/edit_form_page.dart';
import 'package:mood_manager/features/mood_manager/presentation/pages/mood_form_page.dart';
import 'package:mood_manager/features/mood_manager/presentation/pages/t_mood_list_page.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/my_home.dart';
import 'package:mood_manager/features/mood_manager/presentation/widgets/sticky_header.dart';
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
          home: TMoodListPage(),
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
                    case '/edit':
                      return EditFormPage(arguments: settings.arguments);
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
                  return effectMap[PageTransitionType.slideInLeft](
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
