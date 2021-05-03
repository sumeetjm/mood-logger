import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:mood_manager/core/constants/app_constants.dart';
import 'package:mood_manager/core/util/date_util.dart';
import 'package:mood_manager/features/reminder/data/models/task_repeat_parse.dart';
import 'package:mood_manager/features/reminder/domain/entities/task_repeat.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

final weekDays = [
  'monday',
  'tuesday',
  'wednesday',
  'thursday',
  'friday',
  'saturday',
  'sunday',
];

// ignore: must_be_immutable
class TaskRepeatDialog extends StatefulWidget {
  TaskRepeat taskRepeat;
  DateTime dateTime;
  TaskRepeatDialog(this.taskRepeat, this.dateTime);
  @override
  _TaskRepeatDialogState createState() =>
      _TaskRepeatDialogState(taskRepeat, dateTime);
}

class _TaskRepeatDialogState extends State<TaskRepeatDialog> {
  String repeatType = 'Once';
  DateTime validUpto;
  final dateRangePickerController = DateRangePickerController();

  _TaskRepeatDialogState(TaskRepeat taskRepeat, DateTime dateTime) {
    if (taskRepeat != null) {
      repeatType = taskRepeat.repeatType;
      dateRangePickerController.selectedDates =
          taskRepeat.selectedDateList ?? [dateTime];
    }
  }

  @override
  void initState() {
    if (widget.taskRepeat != null) {
      validUpto = widget.taskRepeat.validUpto ??
          widget.dateTime.add(Duration(days: 30));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop()),
                IconButton(
                    icon: Icon(Icons.done),
                    onPressed: () {
                      Navigator.of(context).pop(TaskRepeatParse(
                        id: widget.taskRepeat?.id,
                        repeatType: repeatType,
                        selectedDateList: repeatType == 'Selected dates'
                            ? dateRangePickerController.selectedDates
                            : [],
                        validUpto: validUpto,
                      ));
                    })
              ],
            ),
            DropdownButtonFormField<String>(
              items: [
                DropdownMenuItem(
                  child: Text('Once'),
                  value: 'Once',
                  onTap: () {
                    dateRangePickerController.selectedDates = [widget.dateTime];
                    validUpto = widget.dateTime.add(Duration(days: 30));
                  },
                ),
                DropdownMenuItem(
                  child: Text('Daily'),
                  value: 'Daily',
                  onTap: () {
                    dateRangePickerController.selectedDates = List.generate(
                        validUpto.difference(widget.dateTime).inDays,
                        (index) => widget.dateTime.add(Duration(days: index)));
                    validUpto = widget.dateTime.add(Duration(days: 30));
                  },
                ),
                DropdownMenuItem(
                  child: Text('Selected dates'),
                  value: 'Selected dates',
                  onTap: () {
                    dateRangePickerController.selectedDates =
                        (widget.taskRepeat?.selectedDateList ?? []).isEmpty
                            ? [widget.dateTime]
                            : widget.taskRepeat?.selectedDateList;
                    validUpto = widget.dateTime.add(Duration(days: 30));
                  },
                ),
              ],
              onChanged: (value) {
                setState(() {
                  repeatType = value;
                });
              },
              value: repeatType,
            ),
            /*if (repeatType == 'Selected days')
              ChipsChoice<String>.multiple(
                itemConfig: ChipsChoiceItemConfig(),
                value: selectedDays ?? [],
                options: ChipsChoiceOption.listFrom<String, String>(
                  source: weekDays ?? [],
                  value: (i, v) => v,
                  label: (i, v) => v,
                ),
                onChanged: (List<String> value) {
                  setState(() {
                    selectedDays = [
                      ...value,
                      weekDays[widget.dateTime.weekday - 1]
                    ].toSet().toList();
                  });
                },
                isWrapped: true,
              ),*/
            if (repeatType == 'Daily' || repeatType == 'Selected dates')
              Container(
                child: Column(
                  children: [
                    /* Row(
                      children: weekDays
                          .map((day) => CircleAvatar(
                                child: Text(day.substring(0, 1)),
                              ))
                          .toList(),
                    ),*/
                    SfDateRangePicker(
                      controller: dateRangePickerController,
                      enablePastDates: false,
                      maxDate: validUpto,
                      onSelectionChanged:
                          (dateRangePickerSelectionChangedArgs) {
                        setState(() {
                          repeatType = 'Selected dates';
                          final selectedDates = List<DateTime>.from([
                            ...dateRangePickerSelectionChangedArgs.value,
                            DateUtil.getDateOnly(widget.dateTime)
                          ]).toSet().toList();
                          dateRangePickerController.selectedDates =
                              selectedDates;
                        });
                      },
                      selectionMode: DateRangePickerSelectionMode.multiple,
                    ),
                  ],
                ),
              ),
            if (repeatType == 'Daily' || repeatType == 'Selected dates')
              Center(
                child: GestureDetector(
                  onTap: () async {
                    var date = await showDatePicker(
                        context: context,
                        initialDate: validUpto,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 30)));
                    if (date != null) {
                      setState(() {
                        validUpto = date;
                        dateRangePickerController.selectedDates =
                            dateRangePickerController.selectedDates
                                .where((element) => element
                                    .isBefore(DateUtil.getDateOnly(date)))
                                .toList();
                      });
                    }
                  },
                  child: Text(
                      'Valid upto: ${DateFormat(AppConstants.HEADER_DATE_FORMAT).format(validUpto)}'),
                ),
              ),
          ],
        ),
      ),
    ));
  }
}
