import 'package:flutter/material.dart';
import 'package:tinycolor/tinycolor.dart';

class TimePickerButton extends StatelessWidget {
  const TimePickerButton(
      {Key key,
      this.selectedTime,
      this.selectTime,
      this.textStyle,
      this.enabled = true})
      : super(key: key);
  final TimeOfDay selectedTime;
  final ValueChanged<TimeOfDay> selectTime;
  final TextStyle textStyle;
  final bool enabled;

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light().copyWith(
              primary: Theme.of(context).accentColor,
            ),
            primaryColor: Colors.red, //Head background
            accentColor: Colors.red, //selection color
            dialogBackgroundColor: Colors.white, //Background color
          ),
          child: child,
        );
      },
    );
    if (picked != null && picked != selectedTime) selectTime(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: ElevatedButton(
      style: ElevatedButton.styleFrom(
          primary: TinyColor(Theme.of(context).primaryColor).color,
          onPrimary: Colors.white),
      child: Text(
        selectedTime.format(context),
        style: textStyle ?? TextStyle(fontSize: 20),
      ),
      onPressed: () {
        if (enabled) {
          _selectTime(context);
        }
      },
    ));
  }
}
