import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DateHeader extends StatelessWidget {
  const DateHeader({
    Key key,
    @required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    final headerColor = Provider.of<Color>(context);
    return Container(
        height: 30,
        decoration: new BoxDecoration(
            color: headerColor,
            borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(15.0),
              topRight: const Radius.circular(15.0),
            )),
        child: Center(
            child: Text(
          text,
          style: TextStyle(
              color: Colors.grey[50],
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic),
        )));
  }
}
