import 'package:flutter/material.dart';

class TimePicker extends StatelessWidget {
  const TimePicker(
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
    return GestureDetector(
      child: Center(
        child: Text(
          selectedTime.format(context),
          style: textStyle ?? TextStyle(fontSize: 20),
        ),
      ),
      onTap: () {
        if (enabled) {
          _selectTime(context);
        }
      },
    );
  }
}
