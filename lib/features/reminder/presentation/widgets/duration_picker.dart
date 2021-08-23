import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:mood_manager/home.dart';

// ignore: must_be_immutable
class DurationPicker extends StatefulWidget {
  Duration duration;
  final ValueChanged<Duration> submitCallback;

  DurationPicker({this.submitCallback, this.duration = const Duration()});

  @override
  _DurationPickerState createState() => _DurationPickerState();
}

class _DurationPickerState extends State<DurationPicker> {
  @override
  Widget build(BuildContext context) {
    return Container(
      //height: 200,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      Navigator.of(appNavigatorContext(context)).pop();
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                    icon: Icon(
                      Icons.check,
                    ),
                    onPressed: () {
                      widget.submitCallback(widget.duration);
                      Navigator.of(appNavigatorContext(context)).pop();
                    }),
              )
            ],
          ),
          Divider(
            thickness: 1,
            height: 1,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('hours'),
              Text('minutes'),
              Text('seconds'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Card(
                child: NumberPicker(
                  itemHeight: 30,
                  minValue: 0,
                  maxValue: 23,
                  value: widget.duration.inHours % 24,
                  onChanged: (value) {
                    setState(() {
                      widget.duration = Duration(
                          hours: value,
                          minutes: widget.duration.inMinutes % 60,
                          seconds: widget.duration.inSeconds % 60);
                    });
                  },
                ),
              ),
              Card(
                child: NumberPicker(
                  itemHeight: 30,
                  minValue: 0,
                  maxValue: 59,
                  value: widget.duration.inMinutes % 60,
                  onChanged: (value) {
                    setState(() {
                      widget.duration = Duration(
                          hours: widget.duration.inHours % 24,
                          minutes: value,
                          seconds: widget.duration.inSeconds % 60);
                    });
                  },
                ),
              ),
              Card(
                  child: NumberPicker(
                itemHeight: 30,
                minValue: 0,
                maxValue: 59,
                value: widget.duration.inSeconds % 60,
                onChanged: (value) {
                  setState(() {
                    widget.duration = Duration(
                        hours: widget.duration.inHours % 24,
                        minutes: widget.duration.inMinutes % 60,
                        seconds: value);
                  });
                },
              ))
            ],
          ),
        ],
      ),
    );
  }
}
