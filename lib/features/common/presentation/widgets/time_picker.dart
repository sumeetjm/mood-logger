import 'package:flutter/material.dart';

class TimePicker extends StatelessWidget {
  const TimePicker(
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
    return GestureDetector(
      child: Center(
        child: Text(
          selectedTime.format(context),
          style: textStyle ?? TextStyle(fontSize: 20),
        ),
      ),
      onTap: () {
        _selectTime(context);
      },
    );
  }
}
