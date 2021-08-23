import 'package:flutter/material.dart';

class EmailField extends StatelessWidget {
  final String label;
  final FocusNode focusNode;
  final TextEditingController emailController;
  const EmailField({
    Key key,
    @required this.emailController,
    this.label,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 50, right: 50),
      child: Container(
        height: 60,
        width: MediaQuery.of(context).size.width,
        child: TextField(
          focusNode: focusNode,
          controller: emailController,
          style: TextStyle(
            color: Colors.white,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            fillColor: Colors.lightBlueAccent,
            labelText: label ?? 'Username/Email',
            labelStyle: TextStyle(
              color: Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}
