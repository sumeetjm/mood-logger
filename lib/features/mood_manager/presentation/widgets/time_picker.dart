import 'package:flutter/material.dart';
import 'package:tinycolor/tinycolor.dart';

class TimePicker extends StatelessWidget {
  const TimePicker({Key key, this.selectedTime, this.selectTime})
      : super(key: key);
  final TimeOfDay selectedTime;
  final ValueChanged<TimeOfDay> selectTime;

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay picked =
        await showTimePicker(context: context, initialTime: selectedTime);
    if (picked != null && picked != selectedTime) selectTime(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: RaisedButton(
      color: TinyColor(Theme.of(context).buttonColor).brighten(40).color,
      child: Text(
        selectedTime.format(context),
        style: TextStyle(fontSize: 20),
      ),
      onPressed: () {
        _selectTime(context);
      },
    ));
  }
}
