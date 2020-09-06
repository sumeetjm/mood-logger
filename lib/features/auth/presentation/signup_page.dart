import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mood_manager/features/auth/domain/entitles/user.dart';
import 'package:mood_manager/features/auth/presentation/bloc/authentication_bloc.dart';
import 'package:mood_manager/features/auth/presentation/bloc/signup_bloc.dart';
import 'package:mood_manager/features/auth/presentation/widgets/auth_page_link_button.dart';
import 'package:mood_manager/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:mood_manager/features/auth/presentation/widgets/email_field.dart';
import 'package:mood_manager/features/auth/presentation/widgets/password_field.dart';
import 'package:mood_manager/injection_container.dart';

class SignupPage extends StatefulWidget {
  final Map<String, Object> arguments;
  @override
  _SignupPageState createState() => _SignupPageState();

  SignupPage(this.arguments);
}

class _SignupPageState extends State<SignupPage> {
  SignupBloc _signupBloc;

  @override
  void initState() {
    super.initState();
    _signupBloc = sl<SignupBloc>();
    _emailController = TextEditingController(text: '');
    _passwordController = TextEditingController(text: '');
  }

  TextEditingController _emailController;
  TextEditingController _passwordController;
  @override
  Widget build(BuildContext context) {
    return BlocListener<SignupBloc, SignupState>(
      cubit: _signupBloc,
      listener: (BuildContext context, SignupState state) {
        if (state is SignupSuccess) {
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
        child: BlocBuilder<SignupBloc, SignupState>(
          cubit: _signupBloc,
          builder: (BuildContext context, SignupState state) {
            return ListView(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Column(children: <Widget>[
                      SizedBox(
                        height: 155,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 10),
                        child: RotatedBox(
                            quarterTurns: 0,
                            child: Text(
                              'Sign up',
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
                    AuthPageLinkButton(
                      text: 'Already signed up? Login',
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/login');
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
      print('Email and password cannot be empty');
      return;
    }
    _signupBloc.add(
      SignupRequest(
        user: User(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      ),
    );
  }
}
