import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:mood_manager/features/auth/domain/entitles/user_credenial.dart';
import 'package:mood_manager/features/auth/presentation/bloc/authentication_bloc.dart';
import 'package:mood_manager/features/auth/presentation/bloc/login_bloc.dart';
import 'package:mood_manager/features/auth/presentation/widgets/auth_page_link_button.dart';
import 'package:mood_manager/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:mood_manager/features/auth/presentation/widgets/email_field.dart';
import 'package:mood_manager/features/auth/presentation/widgets/password_field.dart';
import 'package:mood_manager/injection_container.dart';

class LoginPage extends StatefulWidget {
  final Map<String, Object> arguments;
  @override
  _LoginPageState createState() => _LoginPageState();
  LoginPage(this.arguments);
}

class _LoginPageState extends State<LoginPage> {
  LoginBloc _loginBloc;

  @override
  void initState() {
    super.initState();
    _loginBloc = sl<LoginBloc>();
    _emailController = TextEditingController(text: "");
    _passwordController = TextEditingController(text: "");
  }

  TextEditingController _emailController;
  TextEditingController _passwordController;
  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _loginBloc,
      listener: (BuildContext context, LoginState state) {
        if (state is LoginSuccess) {
          BlocProvider.of<AuthenticationBloc>(context).add(LoggedIn());
        }
      },
      child: Scaffold(
          body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.blueGrey, Colors.lightBlueAccent]),
        ),
        child: BlocBuilder(
          bloc: _loginBloc,
          builder: (BuildContext context, LoginState state) {
            return ListView(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Column(children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0, left: 10.0),
                        child: Container(
                          height: 125,
                          child: Column(
                            children: <Widget>[
                              Container(
                                height: 10,
                              ),
                              Center(
                                child: Text(
                                  'You personal mood tracker',
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 10),
                        child: RotatedBox(
                            quarterTurns: 0,
                            child: Text(
                              'Sign in',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                              ),
                            )),
                      ),
                    ]),
                    EmailField(emailController: _emailController),
                    PasswordField(passwordController: _passwordController),
                    AuthSubmitButton(
                      onPressed: _onFormSubmitted,
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 30, left: 30),
                        child: Container(
                          alignment: Alignment.topRight,
                          //height: 30,
                          child: Center(
                              child: Column(
                            children: <Widget>[
                              SignInButton(
                                Buttons.Google,
                                onPressed: _loginWithGoogle,
                              ),
                              SignInButton(
                                Buttons.Facebook,
                                onPressed: () {},
                              )
                            ],
                          )),
                        )),
                    AuthPageLinkButton(
                      text: "Don't have account yet? Sign up",
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/signup');
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      )),
    );
  }

  void _onFormSubmitted() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      print("Email and password cannot be empty");
      return;
    }
    _loginBloc.add(
      LoginRequest(
        userCredential: UserCredential(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      ),
    );
  }

  void _loginWithGoogle() {
    _loginBloc.add(LoginWithGoogleRequest());
  }
}
