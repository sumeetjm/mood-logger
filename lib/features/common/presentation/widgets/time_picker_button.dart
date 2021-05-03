import 'package:flutter/material.dart';
import 'package:tinycolor/tinycolor.dart';

class TimePickerButton extends StatelessWidget {
  const TimePickerButton(
      {Key key, this.selectedTime, this.selectTime, this.textStyle})
      : super(key: key);
  final TimeOfDay selectedTime;
  final ValueChanged<TimeOfDay> selectTime;
  final TextStyle textStyle;

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay picked =
        await showTimePicker(context: context, initialTime: selectedTime);
    if (picked != null && picked != selectedTime) selectTime(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: ElevatedButton(
      style: ElevatedButton.styleFrom(
          primary: TinyColor(Theme.of(context).buttonColor).brighten(40).color,
          onPrimary: Colors.black),
      child: Text(
        selectedTime.format(context),
        style: textStyle ?? TextStyle(fontSize: 20),
      ),
      onPressed: () {
        _selectTime(context);
      },
    ));
  }
}
