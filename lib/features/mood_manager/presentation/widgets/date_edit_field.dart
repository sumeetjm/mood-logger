import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mood_manager/core/constants/app_constants.dart';
import 'package:intl/intl.dart';

class DateEditField extends StatefulWidget {
  DateEditField({
    Key key,
    @required this.label,
    @required this.labelColor,
    @required this.valueColor,
    @required this.value,
    @required this.onChange,
  }) : super(key: key);

  DateTime value;
  final String label;
  final Color labelColor;
  final Color valueColor;
  final ValueChanged<DateTime> onChange;

  @override
  State<StatefulWidget> createState() => _DateEditFieldState();
}

class _DateEditFieldState extends State<DateEditField> {
  TextEditingController controller;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      width: MediaQuery.of(context).size.width,
      child: InkWell(
        onTap: () {
          _selectDate(context);
        },
        child: IgnorePointer(
          child: TextField(
            controller: controller,
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            style: TextStyle(color: widget.valueColor, fontSize: 16),
            decoration: InputDecoration(
              enabledBorder: InputBorder.none,
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.edit,
                  size: 18,
                ),
                onPressed: () {},
              ),
              fillColor: Colors.lightBlueAccent,
              labelText: widget.label,
              labelStyle: TextStyle(color: widget.labelColor, fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: widget.value,
        firstDate: DateTime(1900),
        lastDate: DateTime.now());
    if (picked != null) {
      setState(() {
        widget.value = picked;
        controller.text =
            DateFormat(AppConstants.HEADER_DATE_FORMAT).format(widget.value);
        widget.onChange(widget.value);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(
        text: DateFormat(AppConstants.HEADER_DATE_FORMAT).format(widget.value));
  }
}
