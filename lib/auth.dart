import 'package:flutter/material.dart';
import 'package:mood_manager/features/auth/presentation/login_page.dart';
import 'package:mood_manager/features/auth/presentation/signup_page.dart';

class AuthApp extends StatelessWidget {
  const AuthApp({
    Key key,
  }) : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(null),
      onGenerateRoute: (RouteSettings settings) {
        print(
          'build route for ${settings.name}',
        );
        final routes = <String, WidgetBuilder>{
          '/signup': (context) => SignupPage(settings.arguments),
          '/login': (context) => LoginPage(settings.arguments),
        };
        WidgetBuilder builder = routes[settings.name];
        return MaterialPageRoute(builder: (ctx) => builder(ctx));
      },
    );
  }
}
