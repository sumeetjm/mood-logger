import 'package:flutter/material.dart';

class AuthPageLinkButton extends StatelessWidget {
  final Function onPressed;
  final String text;
  const AuthPageLinkButton(
      {Key key, @required this.onPressed, @required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, left: 30),
      child: Container(
        alignment: Alignment.topRight,
        //color: Colors.red,
        height: 50,
        child: Center(
          child: TextButton(
            onPressed: onPressed,
            child: Text(
              text,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ),
      ),
    );
  }
}
